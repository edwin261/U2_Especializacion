import { useState, useContext } from "react";
import api from "../services/api";
import { AuthContext } from "../context/AuthContext";
import "../styles/login.css";

function Login() {
    const { login } = useContext(AuthContext);
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const handleLogin = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError("");
        try {
            const response = await api.post("/auth/login", {
                email,
                password
            });

            login(
                response.data.token,
                response.data.username,
                response.data.userId,
                response.data.productCount
            );
        }
        catch (err) {
            setError(
                err.response?.data?.message ||
                "Error al iniciar sesión"
            );
        }
        finally {
            setLoading(false);
        }
    };

    return (
        <div className="login-container">
            <form
                className="login-card"
                onSubmit={handleLogin}
            >
                <h2>
                    EcoHome Store
                </h2>
                <h3>
                    Chat Corporativo
                </h3>
                <input
                    type="email"
                    placeholder="Correo electrónico"
                    value={email}
                    onChange={(e)=>setEmail(e.target.value)}
                    required
                />
                <input
                    type="password"
                    placeholder="Contraseña"
                    value={password}
                    onChange={(e)=>setPassword(e.target.value)}
                    required
                />
                {
                    error &&
                    <p className="error">
                        {error}
                    </p>
                }
                <button
                    type="submit"
                    disabled={loading}
                >
                    {
                        loading
                        ?
                        "Ingresando..."
                        :
                        "Iniciar sesión"
                    }
                </button>
            </form>
        </div>
    );
}

export default Login
