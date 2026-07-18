SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @now DATETIME2 = SYSDATETIME();

    /* =====================
       USERS
       ===================== */
    IF NOT EXISTS (SELECT 1 FROM [Users] WHERE id = 1)
    BEGIN
        SET IDENTITY_INSERT [Users] ON;
        INSERT INTO [Users] (id, name, email, password_hash, role, created_at)
        VALUES (
            1,
            'Ana Perez',
            'ana@ecohome.com',
            '$2b$10$iakjCjV6gdP3oI13vGK4Mu/IuqCxxImqvJLKrTwHLA0NSscqXAtVG',
            'admin',
            @now
        );
        SET IDENTITY_INSERT [Users] OFF;
    END;

    IF NOT EXISTS (SELECT 1 FROM [Users] WHERE id = 2)
    BEGIN
        SET IDENTITY_INSERT [Users] ON;
        INSERT INTO [Users] (id, name, email, password_hash, role, created_at)
        VALUES (
            2,
            'Carlos Ruiz',
            'carlos@ecohome.com',
            '$2b$10$iakjCjV6gdP3oI13vGK4Mu/IuqCxxImqvJLKrTwHLA0NSscqXAtVG',
            'sales',
            @now
        );
        SET IDENTITY_INSERT [Users] OFF;
    END;

    IF NOT EXISTS (SELECT 1 FROM [Users] WHERE id = 3)
    BEGIN
        SET IDENTITY_INSERT [Users] ON;
        INSERT INTO [Users] (id, name, email, password_hash, role, created_at)
        VALUES (
            3,
            'Laura Diaz',
            'laura@ecohome.com',
            '$2b$10$iakjCjV6gdP3oI13vGK4Mu/IuqCxxImqvJLKrTwHLA0NSscqXAtVG',
            'support',
            @now
        );
        SET IDENTITY_INSERT [Users] OFF;
    END;

    /* =====================
       PRODUCTS
       ===================== */
    IF NOT EXISTS (SELECT 1 FROM [products] WHERE id = 1)
    BEGIN
        SET IDENTITY_INSERT [products] ON;
        INSERT INTO [products] (
            id, name, description, price, stock, category, image_url, status, created_by, created_at, updated_at
        )
        VALUES (
            1,
            'Botella Termica Eco',
            'Botella reutilizable de acero inoxidable de 750ml.',
            18.90,
            45,
            'Hogar',
            '',
            1,
            1,
            @now,
            @now
        );
        SET IDENTITY_INSERT [products] OFF;
    END;

    IF NOT EXISTS (SELECT 1 FROM [products] WHERE id = 2)
    BEGIN
        SET IDENTITY_INSERT [products] ON;
        INSERT INTO [products] (
            id, name, description, price, stock, category, image_url, status, created_by, created_at, updated_at
        )
        VALUES (
            2,
            'Cepillo de Bambu',
            'Cepillo dental biodegradable para uso diario.',
            3.50,
            120,
            'Cuidado Personal',
            '',
            1,
            1,
            @now,
            @now
        );
        SET IDENTITY_INSERT [products] OFF;
    END;

    IF NOT EXISTS (SELECT 1 FROM [products] WHERE id = 3)
    BEGIN
        SET IDENTITY_INSERT [products] ON;
        INSERT INTO [products] (
            id, name, description, price, stock, category, image_url, status, created_by, created_at, updated_at
        )
        VALUES (
            3,
            'Set Bolsas Reutilizables',
            'Pack de 6 bolsas para compras sin plastico.',
            12.00,
            60,
            'Compras',
            '',
            1,
            2,
            @now,
            @now
        );
        SET IDENTITY_INSERT [products] OFF;
    END;

    /* =====================
       MESSAGES
       ===================== */
    IF NOT EXISTS (SELECT 1 FROM [Messages] WHERE id = 1)
    BEGIN
        SET IDENTITY_INSERT [Messages] ON;
        INSERT INTO [Messages] (id, user_id, text, created_at)
        VALUES (
            1,
            1,
            'Buenos dias equipo.',
            DATEADD(MINUTE, -10, @now)
        );
        SET IDENTITY_INSERT [Messages] OFF;
    END;

    IF NOT EXISTS (SELECT 1 FROM [Messages] WHERE id = 2)
    BEGIN
        SET IDENTITY_INSERT [Messages] ON;
        INSERT INTO [Messages] (id, user_id, text, created_at)
        VALUES (
            2,
            2,
            'Tenemos nuevos pedidos pendientes de despacho.',
            DATEADD(MINUTE, -8, @now)
        );
        SET IDENTITY_INSERT [Messages] OFF;
    END;

    IF NOT EXISTS (SELECT 1 FROM [Messages] WHERE id = 3)
    BEGIN
        SET IDENTITY_INSERT [Messages] ON;
        INSERT INTO [Messages] (id, user_id, text, created_at)
        VALUES (
            3,
            3,
            'Soporte listo para atender tickets de hoy.',
            DATEADD(MINUTE, -5, @now)
        );
        SET IDENTITY_INSERT [Messages] OFF;
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
