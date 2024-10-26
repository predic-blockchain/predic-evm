// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract PredicCore {
    enum UpDown {
        Up100,
        Up50,
        Up25,
        Up10,
        Up5,
        Up3,
        Sideways,
        Down3,
        Down5,
        Down10,
        Down25,
        Down50,
        Down90
    }

    struct Prediction {
        uint amount;
        UpDown updown;
    }

    string public name;
    address public token;
    int64 public price;
    bytes32 public pythPriceFeedId;
    bool public isActive;
    bool public isLock;
    IPyth pyth;
    address signer;
    mapping(UpDown => uint) rangeAmounts;
    mapping(address => Prediction) predictions;
    uint totalRewards;
    uint rangeAmount;
    UpDown public win;

    constructor(string memory _name, address _pyth, address _token) {
        name = _name;
        pyth = IPyth(_pyth);
        token = _token;
        signer = msg.sender;
        isActive = true;
        isLock = false;
    }

    modifier isSigner() {
        require(msg.sender == signer, "forbidden access");
        _;
    }

    modifier noLock() {
        require(isLock == false, "locked, wait for next round");
        _;
    }

    function setSigner(address _signer) external isSigner {
        signer = _signer;
    }

    function setIsActive(bool _isActive) external isSigner {
        isActive = _isActive;
    }

    function prediction(uint _amount, UpDown _updown) external payable noLock {
        if (predictions[msg.sender].amount == 0) {
            predictions[msg.sender] = (Prediction(_amount, _updown));
        } else if (predictions[msg.sender].updown == _updown) {
            predictions[msg.sender] = (
                Prediction(predictions[msg.sender].amount + _amount, _updown)
            );
        } else {
            return;
        }
        rangeAmounts[_updown] += _amount;
    }

    function closeRound() external {
        int64 previous = price;
        PythStructs.Price memory priceData = pyth.getPriceNoOlderThan(
            pythPriceFeedId,
            60
        );
        price = priceData.price;

        int64 pourcentage = ((price - previous) / previous) * 100;
        if (pourcentage >= 100 || pourcentage <= -90) {
            range100(pourcentage);
        } else if (pourcentage >= 50 || pourcentage <= -50) {
            range50(pourcentage);
        } else if (pourcentage >= 25 || pourcentage <= -25) {
            range25(pourcentage);
        } else if (pourcentage >= 10 || pourcentage <= -10) {
            range10(pourcentage);
        } else if (pourcentage >= 5 || pourcentage <= -5) {
            range5(pourcentage);
        } else if (pourcentage >= 3 || pourcentage <= -3) {
            range3(pourcentage);
        } else if (pourcentage > -3 && pourcentage < 3) {
            rangeSideways();
        }
        isLock = false;
    }

    function startRound() external {
        isLock = true;
        PythStructs.Price memory priceData = pyth.getPriceNoOlderThan(
            pythPriceFeedId,
            60
        );
        price = priceData.price;
        rangeAmounts[win] = totalRewards;
    }

    function claimReward() external payable {
        if (predictions[msg.sender].amount != 0) {}
    }

    function range100(int64 pourcentage) private {
        if (pourcentage >= 100) {
            win = UpDown.Up100;
            rangeAmount = rangeAmounts[UpDown.Up100];
        } else {
            win = UpDown.Down90;
            rangeAmount = rangeAmounts[UpDown.Down90];
        }
        totalRewards =
            rangeAmounts[UpDown.Up100] +
            rangeAmounts[UpDown.Down90] +
            rangeAmounts[UpDown.Up50] +
            rangeAmounts[UpDown.Down50] +
            rangeAmounts[UpDown.Up25] +
            rangeAmounts[UpDown.Down25] +
            rangeAmounts[UpDown.Up10] +
            rangeAmounts[UpDown.Down10] +
            rangeAmounts[UpDown.Up5] +
            rangeAmounts[UpDown.Down5] +
            rangeAmounts[UpDown.Up3] +
            rangeAmounts[UpDown.Down3] +
            rangeAmounts[UpDown.Sideways];
        rangeAmounts[UpDown.Up100] = 0;
        rangeAmounts[UpDown.Down90] = 0;
        rangeAmounts[UpDown.Up50] = 0;
        rangeAmounts[UpDown.Down50] = 0;
        rangeAmounts[UpDown.Up25] = 0;
        rangeAmounts[UpDown.Down25] = 0;
        rangeAmounts[UpDown.Up10] = 0;
        rangeAmounts[UpDown.Down10] = 0;
        rangeAmounts[UpDown.Up5] = 0;
        rangeAmounts[UpDown.Down5] = 0;
        rangeAmounts[UpDown.Up3] = 0;
        rangeAmounts[UpDown.Down3] = 0;
        rangeAmounts[UpDown.Sideways] = 0;
    }

    function range50(int64 pourcentage) private {
        if (pourcentage >= 50) {
            win = UpDown.Up50;
            rangeAmount = rangeAmounts[UpDown.Up50];
        } else {
            win = UpDown.Down50;
            rangeAmount = rangeAmounts[UpDown.Down50];
        }
        totalRewards =
            rangeAmounts[UpDown.Up50] +
            rangeAmounts[UpDown.Down50] +
            rangeAmounts[UpDown.Up25] +
            rangeAmounts[UpDown.Down25] +
            rangeAmounts[UpDown.Up10] +
            rangeAmounts[UpDown.Down10] +
            rangeAmounts[UpDown.Up5] +
            rangeAmounts[UpDown.Down5] +
            rangeAmounts[UpDown.Up3] +
            rangeAmounts[UpDown.Down3] +
            rangeAmounts[UpDown.Sideways];
        rangeAmounts[UpDown.Up50] = 0;
        rangeAmounts[UpDown.Down50] = 0;
        rangeAmounts[UpDown.Up25] = 0;
        rangeAmounts[UpDown.Down25] = 0;
        rangeAmounts[UpDown.Up10] = 0;
        rangeAmounts[UpDown.Down10] = 0;
        rangeAmounts[UpDown.Up5] = 0;
        rangeAmounts[UpDown.Down5] = 0;
        rangeAmounts[UpDown.Up3] = 0;
        rangeAmounts[UpDown.Down3] = 0;
        rangeAmounts[UpDown.Sideways] = 0;
    }

    function range25(int64 pourcentage) private {
        if (pourcentage >= 25) {
            win = UpDown.Up25;
            rangeAmount = rangeAmounts[UpDown.Up25];
        } else {
            win = UpDown.Down25;
            rangeAmount = rangeAmounts[UpDown.Down25];
        }
        totalRewards =
            rangeAmounts[UpDown.Up25] +
            rangeAmounts[UpDown.Down25] +
            rangeAmounts[UpDown.Up10] +
            rangeAmounts[UpDown.Down10] +
            rangeAmounts[UpDown.Up5] +
            rangeAmounts[UpDown.Down5] +
            rangeAmounts[UpDown.Up3] +
            rangeAmounts[UpDown.Down3] +
            rangeAmounts[UpDown.Sideways];
        rangeAmounts[UpDown.Up25] = 0;
        rangeAmounts[UpDown.Down25] = 0;
        rangeAmounts[UpDown.Up10] = 0;
        rangeAmounts[UpDown.Down10] = 0;
        rangeAmounts[UpDown.Up5] = 0;
        rangeAmounts[UpDown.Down5] = 0;
        rangeAmounts[UpDown.Up3] = 0;
        rangeAmounts[UpDown.Down3] = 0;
        rangeAmounts[UpDown.Sideways] = 0;
    }

    function range10(int64 pourcentage) private {
        if (pourcentage >= 10) {
            win = UpDown.Up10;
            rangeAmount = rangeAmounts[UpDown.Up10];
        } else {
            win = UpDown.Down10;
            rangeAmount = rangeAmounts[UpDown.Down10];
        }
        totalRewards =
            rangeAmounts[UpDown.Up10] +
            rangeAmounts[UpDown.Down10] +
            rangeAmounts[UpDown.Up5] +
            rangeAmounts[UpDown.Down5] +
            rangeAmounts[UpDown.Up3] +
            rangeAmounts[UpDown.Down3] +
            rangeAmounts[UpDown.Sideways];
        rangeAmounts[UpDown.Up10] = 0;
        rangeAmounts[UpDown.Down10] = 0;
        rangeAmounts[UpDown.Up5] = 0;
        rangeAmounts[UpDown.Down5] = 0;
        rangeAmounts[UpDown.Up3] = 0;
        rangeAmounts[UpDown.Down3] = 0;
        rangeAmounts[UpDown.Sideways] = 0;
    }

    function range5(int64 pourcentage) private {
        if (pourcentage >= 5) {
            win = UpDown.Up5;
            rangeAmount = rangeAmounts[UpDown.Up5];
        } else {
            win = UpDown.Down5;
            rangeAmount = rangeAmounts[UpDown.Down5];
        }
        totalRewards = rangeAmounts[UpDown.Up5] + rangeAmounts[UpDown.Down5];
        rangeAmounts[UpDown.Up5] = 0;
        rangeAmounts[UpDown.Down5] = 0;
    }

    function range3(int64 pourcentage) private {
        if (pourcentage >= 3) {
            win = UpDown.Up3;
            rangeAmount = rangeAmounts[UpDown.Up3];
        } else {
            win = UpDown.Down3;
            rangeAmount = rangeAmounts[UpDown.Down3];
        }
        totalRewards = rangeAmounts[UpDown.Up3] + rangeAmounts[UpDown.Down3];
        rangeAmounts[UpDown.Up3] = 0;
        rangeAmounts[UpDown.Down3] = 0;
    }

    function rangeSideways() private {
        win = UpDown.Sideways;
        rangeAmount = rangeAmounts[UpDown.Sideways];
        totalRewards = rangeAmounts[UpDown.Sideways];
        rangeAmounts[UpDown.Sideways] = 0;
    }
}
