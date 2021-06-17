

local json = require("dkjson")
function parseDownloadAddress(url,headers)
        local error = 0
        local result = ""
        local curl = http()
        for k,v in pairs(headers) do
            curl:setHeader(k,v)
        end
        curl:send(0,url,"")
        local status = curl:getStatusCode()
        if status ~= 200 
        then
            error = status
            result = curl:getHeaders()
        else
            result = curl:getBodyContent()
        end
        return error,result
end
--[[
 解析网盘内文件真实下载地址

]]--
function KeyIsExist(tables,key)
    local bResult = false
    for k,v in pairs(tables)
    do
        if k == key
        then
            bResult = true
            return bResult
        end
    end
    return bResult
end
function parseBaiduUserFiles(filePath,userInfo)
    local result = ""
    if (not KeyIsExist(userInfo,"bdstoken")) or (not KeyIsExist(userInfo,"Cookie")) 
    then
        return result
    end
    local url = "https://d.pcs.baidu.com/rest/2.0/pcs/file?method=locatedownload&path=%s&ver=2.0&dtype=0&esl=1&ehps=0&app_id=250528&check_blue=1&bdstoken=%s&vip=0"
    url = string.format(url,filePath,userInfo["bdstoken"])
    print(url)
    local curl = http()
    curl:setHeader("Cookie",userInfo["Cookie"])
    curl:setHeader("User-Agent","netdisk;")
    curl:setHeader("Content-Type","application/x-www-form-urlencoded")
    curl:send(0,url,"")
    local status = curl:getStatusCode()
    if status ~= 200
    then
        print("HTTP Error Code:",status)
        return result
    else
        local str = curl:getBodyContent()
        local document,pos,err = json.decode(str,1,nil)
        if err
        then
            print("Json Error:",err)
            return result
        else
            if document.urls
            then
                for i = 1,#document.urls
                do
                    if document.urls[i]
                    then
                        if document.urls[i].url
                        then
                            result = document.urls[i].url
                            print(result)
                            return result
                        end
                    end
                end
            end
        end
    end
    return result
end

--[[
    测试函数
]]--
function test(task)
    task:send(0,"https://www.baidu.com","")
    local status = task:getStatusCode()
        if status ~= 200 
        then
            error = status
            result = task:getHeaders()
            print(error)
        else
            result = task:getBodyContent()
            print(result)
        end

end