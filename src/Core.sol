// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

contract PredicCore {
    enum UpDown {
        Up10,
        Up5,
        Sideways,
        Down5,
        Down10
    }

    struct Prediction {
        address holder;
        uint quantity;
        UpDown updown;
    }

    string pythPriceFeedId;
    string symbol;
    address token;
    address signer;
    uint total;
    uint price;
    Prediction[] predictions;

    modifier isSigner() {
        if (signer != address(0)) {
            require(msg.sender == signer);
        }
        _;
    }

    function setSigner(address _signer) external isSigner {
        signer = _signer;
    }

    function predic(uint quantity, UpDown updown) external payable {
        predictions.push(Prediction(msg.sender, quantity, updown));
    }

    function reward() external payable isSigner {
        for (uint i = 0; i < predictions.length; i++) {}
        delete predictions;
    }
}
