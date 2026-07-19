import { useContext } from "react";
import { AuthContext } from "../context/AuthContext";
import { disconnectSocket } from "../services/socket";
import "../styles/navbar.css";

function Navbar() {
    const { username, productCount, logout } = useContext(AuthContext);
    const exit = () => {
        disconnectSocket();
        logout();
    };

    return (
        <header className="navbar">
            <h2>EcoHome Chat</h2>
            <div>
                <span>{username} ({productCount})</span>
                <button onClick={exit}>
                    Salir
                </button>
            </div>
        </header>
    );
}

export default Navbar;
