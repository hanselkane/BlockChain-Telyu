pragma solidity ^0.4.18;

contract myCoin {
    mapping (address => uint256) public balanceOf;

    string public name = "myCoin";
    string public symbol = "MY";
    uint256 public max_supply = 123123000000;
    uint256 public unspent_supply = 0;
    uint256 public spendable_supply = 0;
    uint256 public circulating_supply = 0;
    uint256 public decimals = 6;
    uint256 public reward = 25000000;
    uint256 public timeOfLastHalving = now;
    uint public timeOfLastIncrease = now;

    event Transfer(address indexed from, address indexed to,
        uint256 value);
    event Mint(address indexed from, uint256 value);

    constructor() public {
        timeOfLastHalving = now;  
    }

    function updateSupply() internal returns(uint256){
        if(now - timeOfLastHalving >= 2100000 minutes){
            reward /=2;
            timeOfLastHalving = now;
        }

        if(now - timeOfLastIncrease >= 10 seconds){
            uint256 increaseAmount = ((now - timeOfLastIncrease) / 150 seconds) * reward;
            spendable_supply += increaseAmount;
            unspent_supply += increaseAmount;
            timeOfLastIncrease = now;
        }

        circulating_supply = spendable_supply - unspent_supply;
        return circulating_supply;
    }

    function transfer(address _to, uint256 _value)public payable {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        updateSupply();

        // Notify anyone listening that tha transfer occur
        emit Transfer(msg.sender, _to, msg.value);
    }

    function mint() public payable {
        // Check for overflow
        require(balanceOf[msg.sender] + _value >= balanceOf[msg.sender]);
        uint256 _value = msg.value / 100000000;

        updateSupply();

        require(unspent_supply - _value <= unspent_supply);
        unspent_supply -= _value;
        balanceOf[msg.sender] += _value;

        updateSupply();

        emit Mint(msg.sender, _value);
    }

    function withdraw(uint256 amountToWithdraw) public payable returns(bool){
        // Balance given in myCoin
        require(balanceOf[msg.sender] >= amountToWithdraw);
        require(balanceOf[msg.sender] - amountToWithdraw <= balanceOf[msg.sender]);

        // Balance checked in myCoin, then converted to Wei
        balanceOf[msg.sender] -= amountToWithdraw;

        // Added back to supply in myCoin
        unspent_supply += amountToWithdraw;

        // Convert to Wei then transfer
        amountToWithdraw *= 100000000;
        msg.sender.transfer(amountToWithdraw);
        updateSupply();
        return true;
    }
}
