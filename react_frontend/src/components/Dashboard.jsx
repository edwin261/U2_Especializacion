import { useState } from "react";
import Chat from "./Chat";
import Navbar from "./Navbar";
import Products from "./Products";
import "../styles/dashboard.css";

function Dashboard() {
    const [activeModule, setActiveModule] = useState("chat");

    return (
        <div className="dashboard">
            <Navbar />

            <nav className="module-tabs">
                <button
                    className={activeModule === "chat" ? "active" : ""}
                    onClick={() => setActiveModule("chat")}
                >
                    Chat
                </button>
                <button
                    className={activeModule === "products" ? "active" : ""}
                    onClick={() => setActiveModule("products")}
                >
                    Productos
                </button>
            </nav>

            {
                activeModule === "chat"
                    ?
                    <Chat />
                    :
                    <Products />
            }
        </div>
    );
}

export default Dashboard;
