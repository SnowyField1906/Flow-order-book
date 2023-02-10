import { useState, useEffect } from "react";
import * as fcl from "@onflow/fcl";
import "./flow.config";

import getSortedIDs from "./scripts/getSortedIDs";

import AddingFiller from "./components/AddingFiller";
import Loggingin from "./components/Loggingin";
import Offer from "./components/Offer";

function App() {
  const [bidIDs, setBidISs] = useState([]);
  const [askIDs, setAskIDs] = useState([]);

  useEffect(() => {
    async function fetchBidIDs() {
      const bidIDs = await getSortedIDs(true);
      setBidISs(bidIDs);
    }

    async function fetchAskIDs() {
      const askIDs = await getSortedIDs(false);
      setAskIDs(askIDs);
    }

    fetchBidIDs();
    fetchAskIDs();
  }, []);
  return (
    <div className="grid">
      <Loggingin />
      <div className="flex mx-20">
        <div className="grid w-1/2">
          {
            bidIDs.length !== 0
              ? bidIDs.map((id) => {
                return <Offer id={id} isBid={true} />;
              })
              : <div>Loading...</div>
          }
          {
            askIDs.length !== 0
              ? askIDs.map((id) => {
                return <Offer id={id} isBid={false} />;
              })
              : <div>Loading...</div>
          }
        </div>
        <div className="grid w-1/2 place-items-center">
          <AddingFiller />
        </div>
      </div>
    </div>
  );
}

export default App;
