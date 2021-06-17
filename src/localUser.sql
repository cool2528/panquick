create table if not exists usertb(
id int primary key not null,    -- id 主键
name text not null,     -- 用户昵称
isvip int not null, -- 是否是VIP 用户
cookie text not null,   -- 登陆的cookie
pic text not null,  -- 用户的头像
loginstatus int not null);   -- 登陆的状态是否有效 1 有效 0 无效