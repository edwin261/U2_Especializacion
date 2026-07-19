import { useContext } from "react";
import Login from "./components/Login";
import Dashboard from "./components/Dashboard";
import { AuthContext } from "./context/AuthContext";

function App() {
    const { token } = useContext(AuthContext);
    return (
        <div>
            {
                token
                    ?
                    <Dashboard />
                    :
                    <Login />
            }
        </div>
    );
}

export default App;
