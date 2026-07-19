import {
    useCallback,
    useContext,
    useEffect,
    useMemo,
    useState
} from "react";
import api from "../services/api";
import { AuthContext } from "../context/AuthContext";
import "../styles/products.css";

const emptyForm = {
    name: "",
    price: ""
};

function Products() {
    const {
        token,
        userId,
        updateProductCount
    } = useContext(AuthContext);
    const [products, setProducts] = useState([]);
    const [form, setForm] = useState(emptyForm);
    const [editingId, setEditingId] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const authConfig = useMemo(() => ({
        headers: {
            Authorization: `Bearer ${token}`
        }
    }), [token]);

    const refreshProductCount = useCallback(async () => {
        const response = await api.get(
            "/products/my-count",
            authConfig
        );
        updateProductCount(response.data.count);
    }, [authConfig, updateProductCount]);

    const loadProducts = useCallback(async () => {
        setLoading(true);
        setError("");

        try {
            const response = await api.get(
                "/products",
                authConfig
            );
            setProducts(response.data);
            await refreshProductCount();
        }
        catch (err) {
            setError(
                err.response?.data?.message ||
                "No se pudieron cargar los productos"
            );
        }
        finally {
            setLoading(false);
        }
    }, [authConfig, refreshProductCount]);

    useEffect(() => {
        loadProducts();
    }, [loadProducts]);

    const updateForm = (field, value) => {
        setForm(prev => ({
            ...prev,
            [field]: value
        }));
    };

    const resetForm = () => {
        setForm(emptyForm);
        setEditingId(null);
    };

    const saveProduct = async (e) => {
        e.preventDefault();
        setError("");

        try {
            if (editingId) {
                await api.put(
                    `/products/${editingId}`,
                    form,
                    authConfig
                );
            }
            else {
                await api.post(
                    "/products",
                    form,
                    authConfig
                );
            }

            resetForm();
            await loadProducts();
        }
        catch (err) {
            setError(
                err.response?.data?.message ||
                "No se pudo guardar el producto"
            );
        }
    };

    const editProduct = (product) => {
        setEditingId(product.id);
        setForm({
            name: product.name,
            price: product.price
        });
    };

    const deleteProduct = async (productId) => {
        setError("");

        try {
            await api.delete(
                `/products/${productId}`,
                authConfig
            );
            await loadProducts();
        }
        catch (err) {
            setError(
                err.response?.data?.message ||
                "No se pudo eliminar el producto"
            );
        }
    };

    const formatPrice = (price) => {
        return Number(price).toLocaleString("es-CO", {
            style: "currency",
            currency: "COP"
        });
    };

    return (
        <section className="products-module">
            <div className="products-header">
                <h2>Productos</h2>
                <span>{products.length} registrados</span>
            </div>

            <form
                className="product-form"
                onSubmit={saveProduct}
            >
                <input
                    value={form.name}
                    onChange={(e) => updateForm("name", e.target.value)}
                    placeholder="Nombre del producto"
                    required
                />
                <input
                    type="number"
                    min="0"
                    step="0.01"
                    value={form.price}
                    onChange={(e) => updateForm("price", e.target.value)}
                    placeholder="Precio"
                    required
                />
                <button type="submit">
                    {editingId ? "Actualizar" : "Crear"}
                </button>
                {
                    editingId &&
                    <button
                        type="button"
                        className="secondary"
                        onClick={resetForm}
                    >
                        Cancelar
                    </button>
                }
            </form>

            {
                error &&
                <p className="product-error">
                    {error}
                </p>
            }

            {
                loading
                    ?
                    <p className="products-state">Cargando productos...</p>
                    :
                    <div className="products-table-wrap">
                        <table className="products-table">
                            <thead>
                                <tr>
                                    <th>Nombre</th>
                                    <th>Precio</th>
                                    <th>Creador</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                {
                                    products.map(product => {
                                        const canManage = Number(product.created_by) === Number(userId);

                                        return (
                                            <tr key={product.id}>
                                                <td>{product.name}</td>
                                                <td>{formatPrice(product.price)}</td>
                                                <td>{product.User?.name || "Sin creador"}</td>
                                                <td>
                                                    <div className="product-actions">
                                                        <button
                                                            type="button"
                                                            disabled={!canManage}
                                                            onClick={() => editProduct(product)}
                                                        >
                                                            Editar
                                                        </button>
                                                        <button
                                                            type="button"
                                                            className="danger"
                                                            disabled={!canManage}
                                                            onClick={() => deleteProduct(product.id)}
                                                        >
                                                            Eliminar
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        );
                                    })
                                }
                            </tbody>
                        </table>
                    </div>
            }
        </section>
    );
}

export default Products;
