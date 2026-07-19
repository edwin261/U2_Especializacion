import { createContext, useCallback, useState } from "react";

export const AuthContext = createContext();

export function AuthProvider({ children }) {
    const [token, setToken] = useState(
        localStorage.getItem("token") || ""
    );

    const [username, setUsername] = useState(
        localStorage.getItem("name") || ""
    );

    const [userId, setUserId] = useState(
        Number(localStorage.getItem("userId")) || 0
    );

    const [productCount, setProductCount] = useState(
        Number(localStorage.getItem("productCount")) || 0
    );

    const login = (jwt, user, id, count) => {
        localStorage.setItem("token", jwt);
        localStorage.setItem("name", user);
        localStorage.setItem("userId", id);
        localStorage.setItem("productCount", count);
        setToken(jwt);
        setUsername(user);
        setUserId(id);
        setProductCount(count);
    };

    const logout = () => {
        localStorage.removeItem("token");
        localStorage.removeItem("name");
        localStorage.removeItem("userId");
        localStorage.removeItem("productCount");
        setToken("");
        setUsername("");
        setUserId(0);
        setProductCount(0);
    };

    const updateProductCount = useCallback((count) => {
        localStorage.setItem("productCount", count);
        setProductCount(count);
    }, []);

    return (
        <AuthContext.Provider
            value={{
                token,
                username,
                userId,
                productCount,
                login,
                logout,
                updateProductCount
            }}
        >
            {children}
        </AuthContext.Provider>
    );
}
