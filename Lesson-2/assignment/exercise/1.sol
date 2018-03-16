//***
// * @Author: 花夏
// * @Date:   2018-03-16
// * @Email:  liubiao@itoxs.com
// * 第二节： 编写多员工薪资系统
// * @Copyright: Copyright (c) 2018 by huarxia. All Rights Reserved.
// */

pragma solidity ^0.4.14;

// 声明合约方法
contract CompensationSys {
    // 员工月薪定为 1 ether
    // 默认设置 1 ether 好不好，不然非要去update一下，好麻烦
    // 不update就不能添加完金额后查询自己的余额了？
    uint salary = 1 ether;
    // 花夏的薪资地址
    address employee;
    // 发薪时间步长
    // uint constant payStep = 30 days;
    // 方便调试改成 10s
    uint constant payStep = 10 seconds;
    // 上次发薪时间
    uint lastPayDay = now;
    address owner;

    //**
    //* [CompensationSys 这是构造函数？智能合约一部署自动执行然后将所有者赋给 owner？]
    //* @method   CompensationSys
    //* @author 花夏 liubiao@itoxs.com
    //* @datetime 2018-03-13T10:38:31+080
    //*/
    function CompensationSys() {
        owner = msg.sender;
    }

    //**
    //* [updateEmployeeMsg 更新员工地址或者月薪基数]
    //* @method   updateEmployeeMsg
    //* @author 花夏 liubiao@itoxs.com
    //* @datetime 2018-03-13T10:21:58+080
    //* @param    {address}               ads [更新地址]
    //* @param    {uint}                  sly [更新的月薪基数]
    // *** 填写地址处一定要使用英文状态下的双引号 "" ***
    // 例如 "0xca35b7d915458ef540ade6068dfe2f44e8fa733c"
    //*/
    function updateEmployeeMsg(address ads, uint sly) {
        // 检查是否合约所有者，不是的话是不允许改变的哦，要不然嘻嘻嘻~~~
        require(msg.sender == owner);
        paySurplusWages();
        employee = ads;
        salary = sly * 1 ether;
        lastPayDay = now;
    }
    
    //**
    //* [paySurplusWages 在更新地址或者月薪时支付剩余余额]
    //* @method   paySurplusWages
    //* @author 花夏 liubiao@itoxs.com
    //* @datetime 2018-03-13T10:18:51+080
    //*/
    function paySurplusWages() {
        if (employee != 0x0) {
             uint paySurplusWages = salary * (now - lastPayDay) / payStep;
             employee.transfer(paySurplusWages);
        }
    }
    
    //**
    //* [addFund 添加支付金到合约地址]
    //* @method   addFund
    //* @author   花夏 liubiao@itoxs.com
    //* @datetime 2018-03-13T10:20:27+080
    //* @return   返回合约的余额
    //*/
    function addFund() payable returns(uint) {
        // this 指向合约对象
        return this.balance;
    }

    //**
    //* [getPayTimes 获取合约地址还能支付薪水的次数]
    //* @method   getPayTimes
    //* @author 花夏 liubiao@itoxs.com
    //* @datetime 2018-03-13T10:24:27+080
    //* @return   {uint}                [返回合约地址还能支付薪水的次数]
    //*/
    function getPayTimes() returns(uint) {
        return this.balance / salary;
    }

    //**
    //* [hasEnoughPay 查看是否支付足够]
    //* @method   hasEnoughPay
    //* @author 花夏 liubiao@itoxs.com
    //* @datetime 2018-03-13T10:30:36+080
    //* @return   {Boolean}               [返回是否足够支付]
    //*/
    function hasEnoughPay() returns(bool) {
        // ether == 10^18 wei
        // finney == 10^15 wei
        // 然鹅~~ 难道发薪不要手续费？我再加上0.01ether的手续费吧。保证一下。
        return this.balance >= salary + 10 finney;
    }

    //**
    //* [getMyWage 员工自己领取自己的工资]
    //* @method   getMyWage
    //* @author 花夏 liubiao@itoxs.com
    //* @datetime 2018-03-13T10:32:35+080
    //*/
    function getMyWage() {
        require(msg.sender == employee);
        uint curPayDay = lastPayDay + payStep;
        assert(curPayDay <= now);
        assert(hasEnoughPay());
        // 为啥这几个if判断个分开写？不使用 || ？我分别弹出消息提醒用户啊！
        lastPayDay = curPayDay;
        // 这里千万不要交换顺序哦，我猜测可以更改本地时间干坏事情
        employee.transfer(salary);
    }
}
