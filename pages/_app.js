import '../styles/globals.css'
import Link from 'next/link'
import Login from '../pages/Login'

function MyApp({ Component, pageProps }) {
  return (
    <div>
      <nav className="border-b p-6 ">
        <p className="text-4xl font-bold">Metaverse NFT Market</p>
        <div className="flex mt-4 flex space-x-4"></div>
        <div class="flex space-x-4">
        <Link href="/">
          <a className="bg-transparent hover:bg-pink-500 text-pink-700 font-semibold hover:text-white py-2 px-4 border border-pink-500 hover:border-transparent rounded">Home</a>
        </Link>
        <Link href="/create-item">
          <a className="bg-transparent hover:bg-pink-500 text-pink-700 font-semibold hover:text-white py-2 px-4 border border-pink-500 hover:border-transparent rounded">Sell NFT</a>
        </Link>
        <Link href="/my-assets">
          <a className="bg-transparent hover:bg-pink-500 text-pink-700 font-semibold hover:text-white py-2 px-4 border border-pink-500 hover:border-transparent rounded">My NFT</a>        
        </Link>
        <Link href="/creator-dashboard">
          <a className="bg-transparent hover:bg-pink-500 text-pink-700 font-semibold hover:text-white py-2 px-4 border border-pink-500 hover:border-transparent rounded">Dashboard</a>
        </Link>
        </div>
      </nav>
      <Component {...pageProps} />
    </div>
  )
}

export default MyApp
