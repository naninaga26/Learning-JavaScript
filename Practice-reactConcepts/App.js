import React from "react";
import ReactDOM from "react-dom";
import { ParentCard } from "./useCallback/ParentCard";
//react element
//const ele = <h1 id="heading">Learning javascript React</h1>;

//functional component in react is a javascript function returning jsx elemt or react element

// const HeadingComponent = () => (
//   <div>
//     <nav id="navbar">
//       <ul className="nav">
//         <li>Home</li>
//         <li>About</li>
//       </ul>
//     </nav>
//     {ele}
//   </div>
// );

const Header = () => {
  return (
    <div className="header">
      <div className="logo-container">
        <img
          className="logo"
          src="https://upload.wikimedia.org/wikipedia/sco/b/bf/KFC_logo.svg"
        ></img>
      </div>
      <div className="nav-items">
        <ul>
          <li>Home</li>
          <li>About Us</li>
          <li>Contact Us</li>
          <li>Cart</li>
        </ul>
      </div>
    </div>
  );
};
const ResCard = () => {
  return (
    <div className="res-card">
      <img
        className="res-logo"
        alt="res-logo"
        src="https://media-assets.swiggy.com/swiggy/image/upload/fl_lossy,f_auto,q_auto,w_660/502d6ccc803e95343d0324b15f8639da"
      ></img>
      <h3>Meghana Foods</h3>
    </div>
  );
};

const Body = () => {
  return (
    <div className="body">
      <div className="search">Search</div>
      <div className="res-container"><ParentCard/></div>
    </div>
  );
};
const AppLayout = () => {
  return (
    <div className="app">
      {/* <Header /> */}
      <Body/>
    </div>
  );
};

const root = ReactDOM.createRoot(document.getElementById("root"));

root.render(<AppLayout />);
