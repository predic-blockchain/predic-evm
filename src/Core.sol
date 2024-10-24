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
        address holder;
        uint amount;
        UpDown updown;
    }

    string public name;
    address public token;
    int64 public price;
    bytes32 public pythPriceFeedId;
    bool public isActive;
    uint public count;
    IPyth pyth;
    address signer;
    mapping(UpDown => uint) rangeAmounts;
    Prediction[500] predictions;

    constructor(string memory _name, address _pyth, address _token) {
        name = _name;
        pyth = IPyth(_pyth);
        token = _token;
        signer = msg.sender;
        isActive = true;
    }

    modifier isSigner() {
        require(msg.sender == signer);
        _;
    }

    modifier limit() {
        require(predictions.length >= 500);
        _;
    }

    function setSigner(address _signer) external isSigner {
        signer = _signer;
    }

    function setIsActive(bool _isActive) external isSigner {
        isActive = _isActive;
    }

    function prediction(uint _amount, UpDown _updown) external payable limit {
        predictions[count] = (Prediction(msg.sender, _amount, _updown));
        count++;
        rangeAmounts[_updown] += _amount;
    }

    function reward() external payable isSigner {
        int64 previous = price;
        PythStructs.Price memory priceData = pyth.getPriceNoOlderThan(
            pythPriceFeedId,
            60
        );
        price = priceData.price;

        int64 pourcentage = ((price - previous) / previous) * 100;
        UpDown win;
        uint total;
        uint rangeAmount;
        if (pourcentage >= 100 || pourcentage <= -90) {
            (win, total, rangeAmount) = range100(pourcentage);
        } else if (pourcentage >= 50 || pourcentage <= -50) {
            (win, total, rangeAmount) = range50(pourcentage);
        } else if (pourcentage >= 25 || pourcentage <= -25) {
            (win, total, rangeAmount) = range25(pourcentage);
        } else if (pourcentage >= 10 || pourcentage <= -10) {
            (win, total, rangeAmount) = range10(pourcentage);
        } else if (pourcentage >= 5 || pourcentage <= -5) {
            (win, total, rangeAmount) = range5(pourcentage);
        } else if (pourcentage >= 3 || pourcentage <= -3) {
            (win, total, rangeAmount) = range3(pourcentage);
        } else if (pourcentage > -3 && pourcentage < 3) {
            (win, total, rangeAmount) = rangeSideways();
        }

        // send 0.1% to signer to pay fees

        for (uint i = 0; i < predictions.length; i++) {
            if (predictions[i].updown == win) {
                uint predictionPourcentage = (rangeAmount *
                    predictions[i].amount) / 100;
                uint amount = total / predictionPourcentage;
                // send tokens to winner
            }
        }
        delete predictions;
        count = 0;
    }

    function range100(
        int64 pourcentage
    ) private returns (UpDown win, uint total, uint amount) {
        if (pourcentage >= 100) {
            win = UpDown.Up100;
            amount = rangeAmounts[UpDown.Up100];
        } else {
            win = UpDown.Down90;
            amount = rangeAmounts[UpDown.Down90];
        }
        total =
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

    function range50(
        int64 pourcentage
    ) private returns (UpDown win, uint total, uint amount) {
        if (pourcentage >= 50) {
            win = UpDown.Up50;
            amount = rangeAmounts[UpDown.Up50];
        } else {
            win = UpDown.Down50;
            amount = rangeAmounts[UpDown.Down50];
        }
        total =
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

    function range25(
        int64 pourcentage
    ) private returns (UpDown win, uint total, uint amount) {
        if (pourcentage >= 25) {
            win = UpDown.Up25;
            amount = rangeAmounts[UpDown.Up25];
        } else {
            win = UpDown.Down25;
            amount = rangeAmounts[UpDown.Down25];
        }
        total =
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

    function range10(
        int64 pourcentage
    ) private returns (UpDown win, uint total, uint amount) {
        if (pourcentage >= 10) {
            win = UpDown.Up10;
            amount = rangeAmounts[UpDown.Up10];
        } else {
            win = UpDown.Down10;
            amount = rangeAmounts[UpDown.Down10];
        }
        total =
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

    function range5(
        int64 pourcentage
    ) private returns (UpDown win, uint total, uint amount) {
        if (pourcentage >= 5) {
            win = UpDown.Up5;
            amount = rangeAmounts[UpDown.Up5];
        } else {
            win = UpDown.Down5;
            amount = rangeAmounts[UpDown.Down5];
        }
        total = rangeAmounts[UpDown.Up5] + rangeAmounts[UpDown.Down5];
        rangeAmounts[UpDown.Up5] = 0;
        rangeAmounts[UpDown.Down5] = 0;
    }

    function range3(
        int64 pourcentage
    ) private returns (UpDown win, uint total, uint amount) {
        if (pourcentage >= 3) {
            win = UpDown.Up3;
            amount = rangeAmounts[UpDown.Up3];
        } else {
            win = UpDown.Down3;
            amount = rangeAmounts[UpDown.Down3];
        }
        total = rangeAmounts[UpDown.Up3] + rangeAmounts[UpDown.Down3];
        rangeAmounts[UpDown.Up3] = 0;
        rangeAmounts[UpDown.Down3] = 0;
    }

    function rangeSideways()
        private
        returns (UpDown win, uint total, uint amount)
    {
        win = UpDown.Sideways;
        amount = rangeAmounts[UpDown.Sideways];
        total = rangeAmounts[UpDown.Sideways];
        rangeAmounts[UpDown.Sideways] = 0;
    }
}
