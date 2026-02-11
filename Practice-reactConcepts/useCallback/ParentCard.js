import { ChildCard } from "./ChildCard"
import { useState,useCallback } from "react"
export const ParentCard = () =>{
    const [count,setCount] = useState(0)
    console.log("Parent Card Rendered")
   
    return(
        <div>
            <h1>Parent Card</h1>
            <h2>Count: {count}</h2>
            <button onClick={()=>setCount(count+1)}>Parent Button</button>
            <ChildCard handleClick={useCallback(()=>console.log("Button Clicked"),[])} />
        </div>
    )
}