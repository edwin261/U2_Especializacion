const users = [
    {
        id: 1,
        name: "Ana Perez",
        email: "ana@ecohome.com",
        password: "123456",
        role: "admin"
    },
    {
        id: 2,
        name: "Carlos Ruiz",
        email: "carlos@ecohome.com",
        password: "123456",
        role: "sales"
    },
    {
        id: 3,
        name: "Laura Diaz",
        email: "laura@ecohome.com",
        password: "123456",
        role: "support"
    }
];

const products = [
    {
        id: 1,
        name: "Botella Termica Eco",
        price: 18.9,
        created_by: 1,
        created_at: new Date(),
        updated_at: new Date()
    },
    {
        id: 2,
        name: "Cepillo de Bambu",
        price: 3.5,
        created_by: 1,
        created_at: new Date(),
        updated_at: new Date()
    },
    {
        id: 3,
        name: "Set Bolsas Reutilizables",
        price: 12.0,
        created_by: 2,
        created_at: new Date(),
        updated_at: new Date()
    }
];

const messages = [
    {
        id: 1,
        user_id: 1,
        text: "Buenos dias equipo.",
        created_at: new Date(Date.now() - 1000 * 60 * 10)
    },
    {
        id: 2,
        user_id: 2,
        text: "Tenemos nuevos pedidos pendientes de despacho.",
        created_at: new Date(Date.now() - 1000 * 60 * 8)
    },
    {
        id: 3,
        user_id: 3,
        text: "Soporte listo para atender tickets de hoy.",
        created_at: new Date(Date.now() - 1000 * 60 * 5)
    }
];

let nextMessageId = messages.length + 1;
let nextProductId = products.length + 1;

function getUserByEmail(email) {
    return users.find((u) => u.email === email) || null;
}

function getUserById(id) {
    return users.find((u) => u.id === id) || null;
}

function toPublicUser(user) {
    if (!user) {
        return null;
    }

    return {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
    };
}

function getMessages() {
    return [...messages]
        .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
        .map((m) => ({
            ...m,
            User: {
                name: getUserById(m.user_id)?.name || "Usuario"
            }
        }));
}

function addMessage({ user_id, text }) {
    const message = {
        id: nextMessageId,
        user_id,
        text,
        created_at: new Date()
    };

    nextMessageId += 1;
    messages.push(message);

    return message;
}

function getProducts() {
    return [...products]
        .sort((a, b) => a.name.localeCompare(b.name))
        .map((p) => ({
            ...p,
            User: toPublicUser(getUserById(p.created_by))
        }));
}

function getProductById(id) {
    const numericId = Number(id);
    const product = products.find((p) => p.id === numericId);

    if (!product) {
        return null;
    }

    return {
        ...product,
        User: toPublicUser(getUserById(product.created_by))
    };
}

function getMyStatsCount(userId) {
    const numericId = Number(userId);
    const count = products.filter((p) => p.created_by === numericId).length;
    return count;
}

function addProduct(payload, userId) {
    const product = {
        id: nextProductId,
        name: payload.name,
        price: Number(payload.price),
        created_by: userId,
        created_at: new Date(),
        updated_at: new Date()
    };

    nextProductId += 1;
    products.push(product);

    return {
        ...product,
        User: toPublicUser(getUserById(product.created_by))
    };
}

module.exports = {
    getUserByEmail,
    getMessages,
    addMessage,
    getProducts,
    getProductById,
    addProduct,
    getMyStatsCount
};