export const ChildCard = ({handleClick}) =>{
    console.log("Child Card Rendered")
    return(
        <div>
            <h1>Child Card</h1>
            <button onClick={handleClick}>Click Me</button>
        </div>
    )
}