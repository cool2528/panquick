#include "dcmtk/config/osconfig.h"
BEGIN_EXTERN_C
#ifdef HAVE_FCNTL_H
#include <fcntl.h>       /* for O_RDONLY */
#endif
END_EXTERN_C
#include "dcmtk/ofstd/ofstream.h"
#include "dcmtk/dcmpstat/dvpsdef.h"     /* for constants and macros */
#include "dcmtk/dcmpstat/dviface.h"
#include "dcmtk/ofstd/ofbmanip.h"       /* for OFBitmanipTemplate */
#include "dcmtk/ofstd/ofdatime.h"       /* for OFDateTime */
#include "dcmtk/dcmdata/dcuid.h"        /* for dcmtk version name */
#include "dcmtk/dcmnet/diutil.h"
#include "dcmtk/dcmdata/cmdlnarg.h"
#include "dcmtk/ofstd/ofconapp.h"
#include "dcmtk/dcmpstat/dvpsprt.h"
#include "dcmtk/dcmpstat/dvpshlp.h"
#include "dcmtk/oflog/fileap.h"
#ifdef WITH_OPENSSL
#include "dcmtk/dcmtls/tlstrans.h"
#include "dcmtk/dcmtls/tlslayer.h"
#endif
#ifdef WITH_ZLIB
#include <zlib.h>        /* for zlibVersion() */
#endif
#define OFFIS_CONSOLE_APPLICATION "aijia"
static char rcsid[] = "$dcmtk: " OFFIS_CONSOLE_APPLICATION " v"
  OFFIS_DCMTK_VERSION " " OFFIS_DCMTK_RELEASEDATE " $";

static OFBool      opt_binaryLog = OFFalse;
static OFBool      opt_logFile   = OFFalse;
static const char *opt_cfgName   = NULL;                /* config file name */
static const char *opt_printer   = NULL;                /* printer name */

int main(){

    if (opt_cfgName)
    {
      FILE *cfgfile = fopen(opt_cfgName, "rb");
      if (cfgfile) fclose(cfgfile); else
      {
        std::cout <<  "can't open configuration file '" << opt_cfgName << "'";
        return 10;
      }
    } else {
        std::cout << "no configuration file specified";
        return 10;
    }
    //配置文件的操作
    DVInterface dvi(opt_cfgName);
    if (opt_printer)
    {
      if (DVPSE_printLocal != dvi.getTargetType(opt_printer))
      {
        std::cout <<  "no print scp definition for '" << opt_printer << "' found in config file";
        return 10;
      }
    } else {
      opt_printer = dvi.getTargetID(0, DVPSE_printLocal); // use default print scp
      if (opt_printer==NULL)
      {
        std::cout << "no default print scp available - no config file?";
        return 10;
      }
    }
    opt_binaryLog = dvi.getBinaryLog();
    OFString logfileprefix;
    OFString aString;
    unsigned long logcounter = 0;
    char logcounterbuf[20];

    logfileprefix = dvi.getSpoolFolder();

    logfileprefix += PATH_SEPARATOR;
    logfileprefix += "PrintSCP_";
    logfileprefix += opt_printer;
    logfileprefix += "_";
    DVPSHelper::currentDate(aString);
    logfileprefix += aString;
    logfileprefix += "_";
    DVPSHelper::currentTime(aString);
    logfileprefix += aString;
    if (opt_logFile)
    {
      const char *pattern = "%m%n";
      OFString logfilename = logfileprefix;
      logfilename += ".log";

      OFunique_ptr<dcmtk::log4cplus::Layout> layout(new dcmtk::log4cplus::PatternLayout(pattern));
      dcmtk::log4cplus::SharedAppenderPtr logfile(new dcmtk::log4cplus::FileAppender(logfilename));
      dcmtk::log4cplus::Logger log = dcmtk::log4cplus::Logger::getRoot();

      logfile->setLayout(OFmove(layout));
      log.removeAllAppenders();
      log.addAppender(logfile);
    }
          //确保字典数据是否加载
    if (!dcmDataDict.isDictionaryLoaded()){
        std::cout << "no data dictionary loaded, check environment variable: " << DCM_DICT_ENVIRONMENT_VARIABLE;
    }
    //检查一下我们能否进入数据库
    const char *dbfolder = dvi.getDatabaseFolder();
    std::cout << "Using database in directory '" << dbfolder << "'";
    OFCondition cond2 = EC_Normal;
    DcmQueryRetrieveIndexDatabaseHandle *dbhandle = new DcmQueryRetrieveIndexDatabaseHandle(dbfolder, PSTAT_MAXSTUDYCOUNT, PSTAT_STUDYSIZE, cond2);
    delete dbhandle;
    if (cond2.bad())
    {
      std::cout << "Unable to access database '" << dbfolder << "'";
      return 10;
    }
    //从配置文件中获取打印scp数据
    unsigned short targetPort   = dvi.getTargetPort(opt_printer);
    OFBool targetDisableNewVRs  = dvi.getTargetDisableNewVRs(opt_printer);
    OFBool targetUseTLS         = dvi.getTargetUseTLS(opt_printer);

    if (targetPort == 0)
    {
      std::cout << "no or invalid port number for print scp '" << opt_printer << "'";
      return 10;
    }

    if (targetDisableNewVRs)
    {
      dcmDisableGenerationOfNewVRs();
    }

    T_ASC_Network *net = NULL; /* the DICOM network and listen port */
    OFBool finished = OFFalse;
    int connected = 0;
    #ifdef WITH_OPENSSL
    /* TLS目录 */
    const char *current = NULL;
    const char *tlsFolder = dvi.getTLSFolder();
    if (tlsFolder==NULL) tlsFolder = ".";

    /* 证书文件 */
    OFString tlsCertificateFile(tlsFolder);
    tlsCertificateFile += PATH_SEPARATOR;
    current = dvi.getTargetCertificate(opt_printer);
    if (current) tlsCertificateFile += current; else tlsCertificateFile += "sitecert.pem";

    /* 私钥文件 */
    OFString tlsPrivateKeyFile(tlsFolder);
    tlsPrivateKeyFile += PATH_SEPARATOR;
    current = dvi.getTargetPrivateKey(opt_printer);
    if (current) tlsPrivateKeyFile += current; else tlsPrivateKeyFile += "sitekey.pem";

    /* 私钥密码 */
    const char *tlsPrivateKeyPassword = dvi.getTargetPrivateKeyPassword(opt_printer);

    /* 证书验证 */
    DcmCertificateVerification tlsCertVerification = DCV_requireCertificate;
    switch (dvi.getTargetPeerAuthentication(opt_printer))
    {
      case DVPSQ_require:
        tlsCertVerification = DCV_requireCertificate;
        break;
      case DVPSQ_verify:
        tlsCertVerification = DCV_checkCertificate;
        break;
      case DVPSQ_ignore:
        tlsCertVerification = DCV_ignoreCertificate;
        break;
    }

    /* DH参数文件 */
    OFString tlsDHParametersFile;
    current = dvi.getTargetDiffieHellmanParameters(opt_printer);
    if (current)
    {
      tlsDHParametersFile = tlsFolder;
      tlsDHParametersFile += PATH_SEPARATOR;
      tlsDHParametersFile += current;
    }

    /* 随机种子文件*/
    OFString tlsRandomSeedFile(tlsFolder);
    tlsRandomSeedFile += PATH_SEPARATOR;
    current = dvi.getTargetRandomSeed(opt_printer);
    if (current) tlsRandomSeedFile += current; else tlsRandomSeedFile += "siteseed.bin";

    /* CA certificate directory */
    const char *tlsCACertificateFolder = dvi.getTLSCACertificateFolder();
    if (tlsCACertificateFolder==NULL) tlsCACertificateFolder = ".";

    /* key file format */
    DcmKeyFileFormat keyFileFormat = DCF_Filetype_PEM;
    if (! dvi.getTLSPEMFormat()) keyFileFormat = DCF_Filetype_ASN1;

    DcmTLSTransportLayer *tLayer = NULL;
    if (targetUseTLS)
    {
      tLayer = new DcmTLSTransportLayer(NET_ACCEPTOR, tlsRandomSeedFile.c_str(), OFFalse);
      if (tLayer == NULL)
      {
        std::cout << "unable to create TLS transport layer";
        return 1;
      }

      // 确定TLS概要
      OFString profileName;
      const char *profileNamePtr = dvi.getTargetTLSProfile(opt_printer);
      if (profileNamePtr) profileName = profileNamePtr;
      DcmTLSSecurityProfile tlsProfile = TSP_Profile_BCP195;  // default
      if (profileName == "BCP195") tlsProfile = TSP_Profile_BCP195;
      else if (profileName == "BCP195-ND") tlsProfile = TSP_Profile_BCP195_ND;
      else if (profileName == "AES") tlsProfile = TSP_Profile_AES;
      else if (profileName == "BASIC") tlsProfile = TSP_Profile_Basic;
      else if (profileName == "NULL") tlsProfile = TSP_Profile_IHE_ATNA_Unencrypted;
      else
      {
        std::cout << "unknown TLS profile '" << profileName << "', ignoring";
      }

      if (TCS_ok != tLayer->setTLSProfile(tlsProfile))
      {
        std::cout << "unable to select the TLS security profile";
        return 1;
      }

      // activate cipher suites
      if (TCS_ok != tLayer->activateCipherSuites())
      {
        std::cout << "unable to activate the selected list of TLS ciphersuites";
        return 1;
      }

      if (tlsCACertificateFolder && (TCS_ok != tLayer->addTrustedCertificateDir(tlsCACertificateFolder, keyFileFormat)))
      {
        std::cout << "unable to load certificates from directory '" << tlsCACertificateFolder << "', ignoring";
      }
      if ((tlsDHParametersFile.size() > 0) && ! (tLayer->setTempDHParameters(tlsDHParametersFile.c_str())))
      {
        std::cout << "unable to load temporary DH parameter file '" << tlsDHParametersFile << "', ignoring";
      }
      tLayer->setPrivateKeyPasswd(tlsPrivateKeyPassword); // never prompt on console

      if (TCS_ok != tLayer->setPrivateKeyFile(tlsPrivateKeyFile.c_str(), keyFileFormat))
      {
        std::cout <<  "unable to load private TLS key from '" << tlsPrivateKeyFile<< "'";
        return 1;
      }
      if (TCS_ok != tLayer->setCertificateFile(tlsCertificateFile.c_str(), keyFileFormat))
      {
        std::cout << "unable to load certificate from '" << tlsCertificateFile << "'";
        return 1;
      }
      if (! tLayer->checkPrivateKeyMatchesCertificate())
      {
        std::cout << "private key '" << tlsPrivateKeyFile << "' and certificate '" << tlsCertificateFile << "' do not match";
        return 1;
      }
      tLayer->setCertificateVerification(tlsCertVerification);

    }
#else
    if (targetUseTLS)
    {
      std::cout << "not compiled with OpenSSL, cannot use TLS";
      return 10;
    }
#endif
    /*打开监听套接字*/
        OFCondition cond = ASC_initializeNetwork(NET_ACCEPTOR, targetPort, 30, &net);
    if (cond.bad())
    {
      OFString temp_str;
      std::cout << "cannot initialise network:\n" << DimseCondition::dump(temp_str, cond);
      return 1;
    }

#ifdef WITH_OPENSSL
    if (tLayer)
    {
      cond = ASC_setTransportLayer(net, tLayer, 0);
      if (cond.bad())
      {
        OFString temp_str;
        std::cout << DimseCondition::dump(temp_str, cond);
        return 1;
      }
    }
#endif
    //现在删除根权限并恢复到调用用户id(如果我们作为setuid根运行)
    if (OFStandard::dropPrivileges().bad())
    {
        std::cout <<  "setuid() failed, maximum number of processes/threads for uid already running.";
        return 1;
    }
#ifdef HAVE_FORK
    int timeout=1;
#else
    int timeout=1000;
#endif
    while (!finished)
    {
      DVPSPrintSCP printSCP(dvi, opt_printer); // 为每个关联使用新的打印SCP对象

      if (opt_binaryLog)
      {
        aString = logfileprefix;
        aString += "_";
        sprintf(logcounterbuf, "%04ld", ++logcounter);
        aString += logcounterbuf;
        aString += ".dcm";
        printSCP.setDimseLogPath(aString.c_str());
      }

      connected = 0;
      while (!connected)
      {
        connected = ASC_associationWaiting(net, timeout);
        if (!connected) cleanChildren();
      }
      switch (printSCP.negotiateAssociation(*net))
      {
        case DVPSJ_error:
          // 关联已经被删除，我们只是等待下一个客户端连接。
          break;
        case DVPSJ_terminate:
          finished=OFTrue;
          cond = ASC_dropNetwork(&net);
          if (cond.bad())
          {
            OFString temp_str;
            std::cout <<  "cannot drop network:\n" << DimseCondition::dump(temp_str, cond);
            return 10;
          }
          break;
        case DVPSJ_success:
          printSCP.handleClient();
          break;
      }
    }
    // finished
    cleanChildren();
    OFStandard::shutdownNetwork();
    #ifdef WITH_OPENSSL
    if (tLayer)
    {
      if (tLayer->canWriteRandomSeed())
      {
        if (!tLayer->writeRandomSeed(tlsRandomSeedFile.c_str()))
        {
          std::cout <<  "cannot write back random seed file '" << tlsRandomSeedFile << "', ignoring";
        }
      } else {
        std::cout <<  "cannot write back random seed, ignoring";
      }
    }
    delete tLayer;
#endif

 return 0;
}