// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title QmoosaUniversalInsuranceCore
 * @dev Global Multichain Parametric Reinsurance Core Protocol
 */
contract QmoosaUniversalInsuranceCore {
    address public immutable governor;
    uint256 public universalReinsurancePool;
    uint256 public totalCrossChainPolicies;

    struct ChainAdapter {
        bytes32 chainId;
        address gatewayContract;
        bool isAuthorized;
    }

    mapping(bytes32 => ChainAdapter) public chainAdapters;

    event ChainAdapterRegistered(bytes32 indexed chainId, address gateway);
    event ReinsuranceFunded(uint256 amount);
    event CrossChainClaimProcessed(bytes32 indexed chainId, bytes32 indexed claimHash, uint256 payout);

    constructor() {
        governor = msg.sender;
    }

    function registerChain(bytes32 chainId, address gateway) external {
        require(msg.sender == governor, "Unauthorized");
        chainAdapters[chainId] = ChainAdapter({
            chainId: chainId,
            gatewayContract: gateway,
            isAuthorized: true
        });

        emit ChainAdapterRegistered(chainId, gateway);
    }

    function depositReinsuranceLiquidity() external payable {
        universalReinsurancePool += msg.value;
        emit ReinsuranceFunded(msg.value);
    }

    function processCrossChainIndemnity(bytes32 chainId, bytes32 claimHash, uint256 payout, address recipient) external {
        require(chainAdapters[chainId].isAuthorized, "Unauthorized chain");
        require(payout <= universalReinsurancePool, "Exceeds reinsurance pool");

        universalReinsurancePool -= payout;
        payable(recipient).transfer(payout);

        emit CrossChainClaimProcessed(chainId, claimHash, payout);
    }
}
