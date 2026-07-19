import { useEffect, useState, useContext } from "react";
import { connectSocket } from "../services/socket";
import { AuthContext } from "../context/AuthContext";
import Message from "./Message";
import "../styles/chat.css";

function Chat() {

    const { token, username } = useContext(AuthContext);
    const [socket, setSocket] = useState(null);
    const [messages, setMessages] = useState([]);
    const [text, setText] = useState("");
    useEffect(() => {
        const connection = connectSocket(token);
        setSocket(connection);
        connection.on("chat-history", history => {
            setMessages(history);
        });

        connection.on("receive-message", message => {
            setMessages(prev => [
                ...prev,
                message
            ]);
        });

        return () => {
            connection.disconnect();
        };
    }, [token]);

    const sendMessage = () => {
        if (!text.trim()) return;
        if (!socket) return;
        socket.emit("new-message", {
            text
        });

        setText("");
    };

    return (
        <div className="chat-page">
            <div className="messages">
                {
                    messages.map(message => (
                        <Message
                            key={message.id}
                            message={message}
                            currentUser={username}
                        />
                    ))
                }
            </div>

            <div className="send-box">
                <input
                    value={text}
                    onChange={(e)=>setText(e.target.value)}
                    placeholder="Escriba un mensaje..."
                    onKeyDown={(e)=>{
                        if(e.key==="Enter"){
                            sendMessage();
                        }
                    }}
                />

                <button onClick={sendMessage}>
                    Enviar
                </button>
            </div>
        </div>
    );
}

export default Chat;
