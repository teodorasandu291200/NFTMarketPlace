import '../styles/globals.css'
import Link from 'next/link'
import Login from '../components/Login';
import { MoralisProvider } from "react-moralis"

function MyApp({ Component, pageProps }) {


  return (
    <div>
      <nav className="p-20 bg-black font-mono ">
      <MoralisProvider appId="K0O0qsZ1XJIaMxOwqR1Sx86I83eIvscCIp5g7IbY" serverUrl="https://6mnxcqddrcq0.usemoralis.com:2053/server">
        <div className = "flex justify-end ">
                    <Login
                    />
              </div>
        </MoralisProvider>
        <p className="text-4xl font-bold text-white flex-1 flex justify-center mr-auto">Metaverse NFT Market</p>
        <div className="flex mt-4 space-x-4"></div>
        <div className="flex font-mono items-center justify-center space-x-10 ">
        <Link href="/">
          <a className="bg-transparent  text-pink-700 font-semibold hover:text-white align-middle ">Home</a>
        </Link>
        <Link href="/create-item">
          <a className="bg-transparent  text-pink-700 font-semibold hover:text-white">Sell NFT</a>
        </Link>
        <Link href="/my-assets">
          <a className="bg-transparent  text-pink-700 font-semibold hover:text-white">My NFT</a>        
        </Link>
        <Link href="/creator-dashboard">
          <a className="bg-transparent  text-pink-700 font-semibold hover:text-white">Dashboard</a>
        </Link>
        </div>
      </nav>
      <Component {...pageProps} />
    </div>
  )
}

export default MyApp
