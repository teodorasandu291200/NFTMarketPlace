import {ethers} from 'ethers';
import { useEffect, useState } from 'react';
import axios from 'axios';
import Web3Modal from "web3modal"
import { nftaddress, nftmarketaddress } from '../config';
import NFT from '../artifacts/contracts/NFT.sol/NFT.json';
import Market from '../artifacts/contracts/NFTMarket.sol/NFTMarket.json';
import Image from 'next/image'
import Login from '../components/Login';

export default function Home() {
  const [nfts, setNfts] = useState([]);
  const [loadingState, setLoadingState] = useState('not-loaded');

  useEffect(()=>{
    loadNFTs();

  }, []);

  async function loadNFTs(){
    const provider = new ethers.providers.JsonRpcProvider();
    const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider);
    const marketContract = new ethers.Contract(nftmarketaddress, Market.abi, provider);

    //return an array of unsold market items
    const data = await marketContract.fetchMarketItems();

    const items = await Promise.all(data.map(async i => {
       const tokenUri = await tokenContract.tokenURI(i.tokenId);
       const meta = await axios.get(tokenUri);
       let price = ethers.utils.formatUnits(i.price.toString(), 'ether')
       let item = {
         price,
         tokenId: i.tokenId.toNumber(),
         seller: i.seller,
         owner: i.owner,
         image: meta.data.image,
         name: meta.data.name,
         description: meta.data.description,
       }
       return item;
    }));

    setNfts(items);
    setLoadingState('loaded')
  }

  async function buyNFT(nft){
    const web3Modal = new Web3Modal();
    const connection = await web3Modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);

    //sign the transaction
    const signer = provider.getSigner();
    const contract = new ethers.Contract(nftmarketaddress, Market.abi, signer);

    //set the price
    const price = ethers.utils.parseUnits(nft.price.toString(), 'ether');

    //make the sale
    const transaction = await contract.createMarketSale(nftaddress, nft.tokenId, {
      value: price
    });
    await transaction.wait();

    loadNFTs()
  }

  if(loadingState === 'loaded' && !nfts.length) return (
    <h1 className="flex justify-center space-x-4">No items in market place</h1>
  )

  return (
   <div className="flex justify-center ">
     <div className="px-4 pb-2" style={{ maxWidth: '1600px'}}>
      <div className="justify-center grid sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4 ">
        {
          nfts.map((nft, i) =>(
            <div key={i} className=" overflow-hidden ">
             
              <Image
                  src={nft.image}
                  alt="Picture of the author"
                  width={500}
                  height={500}
                  // blurDataURL="data:..." automatically provided
                  // placeholder="blur" // Optional blur-up while loading
              />
              <div className = "grid place-items-center bg-blue-500 ">
                    <Login/>
                </div>

                <div className="p-1 ">
                  <p style={{ height: '50px'}} className="text-2xl font-mono flex justify-center ">
                    {nft.name}
                  </p>
                  <div style={{ height: '30px', overflow: 'hidden'}}>
                    <p className="text-gray-400 flex justify-center font-mono">{nft.description}</p>
                  </div>
                </div>
                <div className="p-4 bg-black ">
                  <p className="text-2xl mb-4 font-mono flex justify-center text-white">
                    {nft.price} ETH
                  </p>
                  <button className="w-full text-pink-700 font-mono hover:text-white font-bold py-2 px-12 text-2xl "
                  onClick={() => buyNFT(nft)}>Buy NFT</button>
                </div>
            </div>
          ))
        }
      </div>
     </div>
   </div>
  )
}