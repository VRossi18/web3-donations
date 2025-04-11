// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

struct Campaign {
    address author;
    string title;
    string description;
    string videoUrl;
    string imageUrl;
    uint256 balance;
    bool active;
}

contract DonateCrypto {

    uint256 public fee = 100;
    uint256 public nextId = 0;

    mapping (uint256 => Campaign) public campaigns; //id => campanha

    function addCampaign(string calldata title, string calldata description, string calldata videoUrl, string calldata imageUrl) public {
        Campaign memory newCampaign;
        newCampaign.title = title;
        newCampaign.description = description;
        newCampaign.videoUrl = videoUrl;
        newCampaign.imageUrl = imageUrl;
        newCampaign.active = true;
        newCampaign.author = msg.sender; 

        nextId++;
        campaigns[nextId] = newCampaign;
    }

    function donate(uint256 id) public payable {
        require(msg.value > 0, "You must send a donation with value greater than 0");
        require(campaigns[id].active == true, "The campaign you are trying to donate is no longer active");

        campaigns[id].balance += msg.value;
    }

    function withdraw(uint256 id) public {
        Campaign memory campaign = campaigns[id];
        require(campaign.author == msg.sender, "You are not the campaign owner");
        require(campaign.active == true, "The campaign you are trying to withdraw is no longer active");
        require(campaign.balance > fee, "This campaign does not have enough balance");

        uint256 amountToWithdraw = campaign.balance - fee;
        (bool success, ) = payable(campaign.author).call{value: amountToWithdraw}("");

        require(success, "Failed to withdraw");
        
        campaigns[id].active = false;
    }
}