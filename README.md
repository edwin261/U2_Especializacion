# U2_Especializacion
Actividad perteneciente a la unidad 2 de la asignatura Optimización y desarrollo avanzado de aplicaciones multiplataforma.

````markdown
# 🏡 EcoHome Store - Chat Interno Corporativo

## 📖 Descripción del Proyecto

EcoHome Store es una empresa dedicada a la comercialización de productos sustentables para el hogar. Con el crecimiento de sus operaciones y el aumento de pedidos en su plataforma de comercio electrónico, surgió la necesidad de centralizar la comunicación entre las áreas de Ventas, Logística y Soporte.

Este proyecto consiste en el desarrollo de un **Chat Interno Corporativo en Tiempo Real**, que permite a los usuarios autenticados intercambiar mensajes de forma segura mediante **Socket.IO**, manteniendo un historial persistente en una base de datos SQL Server.

La aplicación está desarrollada bajo una arquitectura **Cliente-Servidor**, utilizando **React** para el frontend y **Express.js** para el backend, implementando autenticación mediante **JSON Web Token (JWT)** y almacenamiento de mensajes en **SQL Server**.

---

# 🎯 Objetivos

- Implementar comunicación en tiempo real mediante WebSockets.
- Autenticar usuarios utilizando JWT.
- Persistir los mensajes en una base de datos SQL Server.
- Mostrar el historial de los últimos 10 mensajes al iniciar sesión.
- Proporcionar una interfaz web amigable para la comunicación interna de la empresa.

---

# 🏗 Arquitectura del Proyecto

```
EcoHome-Chat
│
├── backend
│   ├── config
│   ├── controllers
│   ├── middleware
│   ├── models
│   ├── routes
│   ├── sockets
│   ├── services
│   ├── app.js
│   ├── server.js
│   └── package.json
│
├── frontend
│   ├── public
│   ├── src
│   │   ├── components
│   │   ├── context
│   │   ├── services
│   │   ├── styles
│   │   ├── App.jsx
│   │   ├── index.js
│   │   └── index.css
│   └── package.json
│
└── README.md
```

---

# 🚀 Tecnologías Utilizadas

## Backend

- Node.js
- Express.js
- Socket.IO
- JSON Web Token (JWT)
- Sequelize ORM
- SQL Server
- bcrypt
- dotenv
- cors

---

## Frontend

- React
- Axios
- Socket.IO Client
- React Context API
- CSS3

---

## Base de Datos

- Microsoft SQL Server

---

# 📋 Requisitos Previos

Antes de ejecutar el proyecto es necesario tener instalado:

- Node.js 18 o superior
- npm
- SQL Server
- SQL Server Management Studio (SSMS) (Opcional)
- Git

---

# ⚙ Instalación del Proyecto

## 1. Clonar el repositorio

```bash
git clone https://github.com/usuario/ecohome-chat.git

cd ecohome-chat
```

---

# 🔧 Instalación del Backend

Entrar a la carpeta del backend

```bash
cd backend
```

Instalar dependencias

```bash
npm install
```

Levantar el servidor en modo desarrollo

```bash
npm run dev
```

O iniciar normalmente

```bash
npm start
```

El servidor quedará disponible en:

```
http://localhost:3001
```

---

# 💻 Instalación del Frontend

Abrir otra terminal

Entrar al proyecto

```bash
cd frontend
```

Instalar dependencias

```bash
npm install
```

Ejecutar React

```bash
npm start
```

La aplicación quedará disponible en:

```
http://localhost:3000
```

---

# 🗄 Configuración de la Base de Datos

Crear una base de datos en SQL Server.

Ejemplo:

```sql
CREATE DATABASE EcoHomeChat;
GO
```

Ejecutar posteriormente los scripts correspondientes para crear las tablas:

- users
- messages

---

# 🔑 Variables de Entorno

Crear un archivo **.env** dentro del backend.

Ejemplo:

```env
PORT=3001

DB_SERVER=localhost
DB_DATABASE=EcoHomeChat
DB_USER=sa
DB_PASSWORD=tu_password

JWT_SECRET=MiClaveSuperSegura123
```

---

# 👤 Funcionalidades Implementadas

- Inicio de sesión mediante JWT.
- Comunicación en tiempo real con Socket.IO.
- Broadcast de mensajes a todos los usuarios conectados.
- Historial de los últimos 10 mensajes.
- Persistencia automática de mensajes en SQL Server.
- Desconexión segura de usuarios.
- Arquitectura organizada para facilitar futuras ampliaciones.

---

# 📂 Flujo General del Sistema

```text
Usuario

    │

    ▼

Login

    │

JWT

    │

    ▼

Backend Express

    │

Socket.IO

    │

SQL Server

    │

Persistencia

    │

    ▼

Todos los clientes reciben el mensaje en tiempo real
```

---

# ▶ Ejecución Completa

### Terminal 1

```bash
cd backend

npm install

npm run dev
```

---

### Terminal 2

```bash
cd frontend

npm install

npm start
```

---

Abrir el navegador

```
http://localhost:3000
```

---

# 📌 Características del Proyecto

- Arquitectura Cliente-Servidor
- Comunicación en Tiempo Real
- Persistencia de Datos
- Seguridad mediante JWT
- Código Modular
- Escalable
- Integración con SQL Server
- Interfaz desarrollada con React

---

# 👨‍💻 Lenguajes de Programación

- JavaScript (ES6+)
- SQL
- HTML5
- CSS3

---

# 📚 Dependencias Principales

## Backend

- express
- socket.io
- sequelize
- tedious
- jsonwebtoken
- bcrypt
- cors
- dotenv

---

## Frontend

- react
- react-dom
- axios
- socket.io-client

---

# 📖 Referencias

- React Documentation
- Express.js Documentation
- Socket.IO Documentation
- Microsoft SQL Server Documentation
- JWT.io
- Sequelize Documentation

---

# 👨‍🎓 Proyecto Académico

Proyecto desarrollado con fines académicos para demostrar la implementación de un sistema de chat corporativo en tiempo real utilizando tecnologías modernas del ecosistema JavaScript, aplicando conceptos de Ingeniería de Software, Arquitectura Cliente-Servidor, Comunicación en Tiempo Real, Seguridad mediante JWT y Persistencia de Datos en SQL Server.
````
