import "./../styles/chat.css";

function Message({ message, currentUser }) {
    const mine = message.username === currentUser;
    return (
        <div
            className={
                mine
                    ? "message mine"
                    : "message"
            }
        >
            <strong>
                {message.username}
            </strong>

            <p>
                {message.text}
            </p>
        </div>
    );
}

export default Message;