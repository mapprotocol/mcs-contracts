// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './NFTToken.sol';

contract NFTBridge is Ownable {
    uint immutable chainId = block.chainid;

    event mapLockNFT(address token, uint tokenID, uint fromChain, uint toChain,uint nativeChain);
    event mapWithdrawNFT(address token, uint tokenID, uint fromChain, uint toChain,uint nativeChain);

    mapping(address => mapping(uint => address)) public wrappedAssets;

    function lockNFT(address _token, uint tokenID, uint toChain) public {
        NFTToken token = NFTToken(_token);
        if (token.nativeContract() != address(0)) {
//            require(token.nativeChain() == toChain, "chain is error");
            token.lock(msg.sender, tokenID);
            emit mapLockNFT(token.nativeContract(), tokenID, chainId, toChain,token.nativeChain());
        } else {
            IERC721(token).transferFrom(msg.sender, address(this), tokenID);
            emit mapLockNFT(_token, tokenID, chainId, toChain,token.nativeChain());
        }
    }

    function withdrawNFT(address _token, address to, uint tokenID, uint fromChain, uint nativeChain,
        string memory name, string memory symbol, string memory tokenURI) public onlyOwner {
        NFTToken token = NFTToken(_token);
        if (chainId == nativeChain) {
            IERC721(token).transferFrom(address(this), to, tokenID);
            emit mapWithdrawNFT(_token, tokenID, fromChain, chainId, nativeChain);
        } else {
            address localWrapped = wrappedAssets[_token][fromChain];
            if (localWrapped == address(0)) {
                token = new NFTToken(name, symbol, _token, fromChain);
                wrappedAssets[_token][fromChain] = address(token);
            } else {
                token = NFTToken(localWrapped);
            }
            token.mint(to, tokenID);
            token.setTokenURI(tokenID, tokenURI);
            emit mapWithdrawNFT(_token, tokenID, fromChain, chainId,token.nativeChain());
        }
    }
}