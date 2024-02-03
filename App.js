import React from "react";
import ReactDOM from "react-dom";

//react element
const ele = <h1 id="heading">Learning javascript React</h1>;

//functional component in react is a javascript function returning jsx elemt or react element

const HeadingComponent = () => (
  <div>
    <nav id="navbar">
      <ul className="nav">
        <li>Home</li>
        <li>About</li>
      </ul>
    </nav>
    {ele}
  </div>
);

console.log(ele);
const root = ReactDOM.createRoot(document.getElementById("root"));

root.render(<HeadingComponent />);
