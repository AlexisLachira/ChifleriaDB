-- Description: Procedimientos almacenados para la gestión de personas, clientes, proveedores y empleados.
CREATE OR ALTER PROCEDURE paPersonaInsertar
    @apePaterno VARCHAR(50),
    @apeMaterno VARCHAR(50),
    @nombre VARCHAR(50),
    @idTipoDocumento INT,
    @numDocumento CHAR(11),
    @idPersona INT OUTPUT,
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no esté vacío
        IF @apePaterno IS NULL OR @apePaterno = ''
            BEGIN
                SET @mensaje = 'El apellido paterno es requerido';
                SET @idPersona = 0;
                RETURN;
            END

        IF @nombre IS NULL OR @nombre = ''
            BEGIN
                SET @mensaje = 'El nombre es requerido';
                SET @idPersona = 0;
                RETURN;
            END

        IF @numDocumento IS NULL OR @numDocumento = ''
            BEGIN
                SET @mensaje = 'El número de documento es requerido';
                SET @idPersona = 0;
                RETURN;
            END

        -- Validar que el tipo de documento existe
        IF NOT EXISTS(SELECT 1 FROM TipoDocumento WHERE id = @idTipoDocumento AND activo = 1)
            BEGIN
                SET @mensaje = 'El tipo de documento especificado no existe';
                SET @idPersona = 0;
                RETURN;
            END

        -- Validar que el documento no exista
        IF EXISTS(SELECT 1 FROM Persona WHERE numDocumento = @numDocumento AND activo = 1)
            BEGIN
                SET @mensaje = 'Ya existe una persona registrada con este documento';
                SET @idPersona = 0;
                RETURN;
            END

        -- Insertar persona
        INSERT INTO Persona (
            apePaterno, apeMaterno, nombre, nombreCompleto,
            idTipoDocumento, numDocumento
        )
        VALUES (
                   @apePaterno, ISNULL(@apeMaterno, ''), @nombre,
                   CONCAT(@apePaterno, ' ', ISNULL(@apeMaterno, ''), ' ', @nombre),
                   @idTipoDocumento, @numDocumento
               );

        SET @idPersona = SCOPE_IDENTITY();
        SET @mensaje = 'Persona registrada exitosamente';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @idPersona = 0;
        SET @mensaje = 'Inserción fallida';
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE paPersonaActualizar
    @id INT,
    @apePaterno VARCHAR(50),
    @apeMaterno VARCHAR(50),
    @nombre VARCHAR(50),
    @idTipoDocumento INT,
    @numDocumento CHAR(11),
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la persona existe
        IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @id AND activo = 1)
            BEGIN
                SET @mensaje = 'La persona no existe o no está activa';
                RETURN;
            END

        -- Validar que no esté vacío
        IF @apePaterno IS NULL OR @apePaterno = ''
            BEGIN
                SET @mensaje = 'El apellido paterno es requerido';
                RETURN;
            END

        IF @nombre IS NULL OR @nombre = ''
            BEGIN
                SET @mensaje = 'El nombre es requerido';
                RETURN;
            END

        IF @numDocumento IS NULL OR @numDocumento = ''
            BEGIN
                SET @mensaje = 'El número de documento es requerido';
                RETURN;
            END

        -- Validar que el tipo de documento existe
        IF NOT EXISTS(SELECT 1 FROM TipoDocumento WHERE id = @idTipoDocumento AND activo = 1)
            BEGIN
                SET @mensaje = 'El tipo de documento especificado no existe';
                RETURN;
            END

        -- Validar que no exista otro con el mismo documento
        IF EXISTS(SELECT 1 FROM Persona
                  WHERE numDocumento = @numDocumento
                    AND id != @id
                    AND activo = 1)
            BEGIN
                SET @mensaje = 'Ya existe otra persona registrada con este documento';
                RETURN;
            END

        -- Actualizar persona
        UPDATE Persona
        SET apePaterno = @apePaterno,
            apeMaterno = ISNULL(@apeMaterno, ''),
            nombre = @nombre,
            nombreCompleto = CONCAT(@apePaterno, ' ', ISNULL(@apeMaterno, ''), ' ', @nombre),
            idTipoDocumento = @idTipoDocumento,
            numDocumento = @numDocumento
        WHERE id = @id;

        SET @mensaje = 'Persona actualizada exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @mensaje = 'Actualización fallida';
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE paPersonaTelefonoInsertar
    @idPersona INT,
    @idTipoTelefono INT,
    @numero CHAR(9),
    @idPersonaTelefono INT OUTPUT,
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el número es válido (9 dígitos)
        IF @numero IS NULL OR @numero = '' OR NOT (@numero LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
            BEGIN
                SET @mensaje = 'El número debe contener exactamente 9 dígitos';
                SET @idPersonaTelefono = 0;
                RETURN;
            END

        -- Validar que la persona existe
        IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @idPersona AND activo = 1)
            BEGIN
                SET @mensaje = 'La persona especificada no existe';
                SET @idPersonaTelefono = 0;
                RETURN;
            END

        -- Validar que el tipo de teléfono existe
        IF NOT EXISTS(SELECT 1 FROM TipoTelefono WHERE id = @idTipoTelefono AND activo = 1)
            BEGIN
                SET @mensaje = 'El tipo de teléfono especificado no existe';
                SET @idPersonaTelefono = 0;
                RETURN;
            END

        -- Insertar teléfono
        INSERT INTO PersonaTelefono (
            idPersona, idTipoTelefono, numero
        )
        VALUES (
                   @idPersona, @idTipoTelefono, @numero
               );

        SET @idPersonaTelefono = SCOPE_IDENTITY();
        SET @mensaje = 'Teléfono registrado exitosamente';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @idPersonaTelefono = 0;
        SET @mensaje = 'Inserción fallida';
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE paPersonaTelefonoActualizar
    @id INT,
    @idPersona INT,
    @idTipoTelefono INT,
    @numero CHAR(9),
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el teléfono existe
        IF NOT EXISTS(SELECT 1 FROM PersonaTelefono WHERE id = @id AND activo = 1)
            BEGIN
                SET @mensaje = 'El teléfono no existe o no está activo';
                RETURN;
            END

        -- Validar que el número es válido
        IF @numero IS NULL OR @numero = '' OR NOT (@numero LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
            BEGIN
                SET @mensaje = 'El número debe contener exactamente 9 dígitos';
                RETURN;
            END

        -- Validar que la persona existe
        IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @idPersona AND activo = 1)
            BEGIN
                SET @mensaje = 'La persona especificada no existe';
                RETURN;
            END

        -- Validar que el tipo de teléfono existe
        IF NOT EXISTS(SELECT 1 FROM TipoTelefono WHERE id = @idTipoTelefono AND activo = 1)
            BEGIN
                SET @mensaje = 'El tipo de teléfono especificado no existe';
                RETURN;
            END

        -- Actualizar teléfono
        UPDATE PersonaTelefono
        SET idPersona = @idPersona,
            idTipoTelefono = @idTipoTelefono,
            numero = @numero
        WHERE id = @id;

        SET @mensaje = 'Teléfono actualizado exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @mensaje = 'Actualización fallida';
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE paClienteInsertar
    @idPersona INT,
    @direccion VARCHAR(100),
    @email VARCHAR(100),
    @razonSocial VARCHAR(150),
    @idCliente INT OUTPUT,
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la persona existe
        IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @idPersona AND activo = 1)
            BEGIN
                SET @mensaje = 'La persona especificada no existe';
                SET @idCliente = 0;
                RETURN;
            END

        -- Validar que la dirección no esté vacía
        IF @direccion IS NULL OR @direccion = ''
            BEGIN
                SET @mensaje = 'La dirección es requerida';
                SET @idCliente = 0;
                RETURN;
            END

        -- Validar email si se proporciona
        IF @email IS NOT NULL AND @email != ''
            BEGIN
                IF NOT (@email LIKE '%_@__%.__%')
                    BEGIN
                        SET @mensaje = 'El formato del email es inválido';
                        SET @idCliente = 0;
                        RETURN;
                    END
            END

        -- Insertar cliente
        INSERT INTO Cliente (
            idPersona, direccion, email, razonSocial
        )
        VALUES (
                   @idPersona, @direccion, @email, @razonSocial
               );

        SET @idCliente = SCOPE_IDENTITY();
        SET @mensaje = 'Cliente registrado exitosamente';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @idCliente = 0;
        SET @mensaje = 'Inserción fallida';
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE paClienteActualizar
    @id INT,
    @idPersona INT,
    @direccion VARCHAR(100),
    @email VARCHAR(100),
    @razonSocial VARCHAR(150),
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el cliente existe
        IF NOT EXISTS(SELECT 1 FROM Cliente WHERE id = @id AND activo = 1)
            BEGIN
                SET @mensaje = 'El cliente no existe o no está activo';
                RETURN;
            END

        -- Validar que la persona existe
        IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @idPersona AND activo = 1)
            BEGIN
                SET @mensaje = 'La persona especificada no existe';
                RETURN;
            END

        -- Validar que la dirección no esté vacía
        IF @direccion IS NULL OR @direccion = ''
            BEGIN
                SET @mensaje = 'La dirección es requerida';
                RETURN;
            END

        -- Validar email si se proporciona
        IF @email IS NOT NULL AND @email != ''
            BEGIN
                IF NOT (@email LIKE '%_@__%.__%')
                    BEGIN
                        SET @mensaje = 'El formato del email es inválido';
                        RETURN;
                    END
            END

        -- Actualizar cliente
        UPDATE Cliente
        SET idPersona = @idPersona,
            direccion = @direccion,
            email = @email,
            razonSocial = @razonSocial
        WHERE id = @id;

        SET @mensaje = 'Cliente actualizado exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @mensaje = 'Actualización fallida';
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE paProveedorInsertar
            @idPersona INT,
            @registroSanitario VARCHAR(50),
            @idProveedor INT OUTPUT,
            @mensaje VARCHAR(500) OUTPUT
        AS
        BEGIN
            SET NOCOUNT ON;
            BEGIN TRY
                BEGIN TRANSACTION;

                -- Validar que la persona existe
                IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @idPersona AND activo = 1)
                    BEGIN
                        SET @mensaje = 'La persona especificada no existe';
                        SET @idProveedor = 0;
                        RETURN;
                    END

                -- Validar que no esté ya registrado como proveedor
                IF EXISTS(SELECT 1 FROM Proveedor WHERE idPersona = @idPersona AND activo = 1)
                    BEGIN
                        SET @mensaje = 'Esta persona ya está registrada como proveedor';
                        SET @idProveedor = 0;
                        RETURN;
                    END

                -- Insertar proveedor
                INSERT INTO Proveedor (
                    idPersona, registroSanitario
                )
                VALUES (
                    @idPersona, @registroSanitario
                );

                SET @idProveedor = SCOPE_IDENTITY();
                SET @mensaje = 'Proveedor registrado exitosamente';

                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @idProveedor = 0;
                SET @mensaje = 'Inserción fallida';
            END CATCH
        END
        GO
CREATE OR ALTER PROCEDURE paProveedorActualizar
    @id INT,
    @idPersona INT,
    @registroSanitario VARCHAR(50),
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el proveedor existe
        IF NOT EXISTS(SELECT 1 FROM Proveedor WHERE id = @id AND activo = 1)
            BEGIN
                SET @mensaje = 'El proveedor no existe o no está activo';
                RETURN;
            END

        -- Validar que la persona existe
        IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @idPersona AND activo = 1)
            BEGIN
                SET @mensaje = 'La persona especificada no existe';
                RETURN;
            END

        -- Validar que no exista otro proveedor con la misma persona
        IF EXISTS(SELECT 1 FROM Proveedor
                  WHERE idPersona = @idPersona
                    AND id != @id
                    AND activo = 1)
            BEGIN
                SET @mensaje = 'Otra persona ya está registrada como proveedor';
                RETURN;
            END

        -- Actualizar proveedor
        UPDATE Proveedor
        SET idPersona = @idPersona,
            registroSanitario = @registroSanitario
        WHERE id = @id;

        SET @mensaje = 'Proveedor actualizado exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @mensaje = 'Actualización fallida';
    END CATCH
END

    CREATE OR ALTER PROCEDURE paEmpleadoInsertar
        @idPersona INT,
        @idTipoEmpleado INT,
        @fechaIngreso DATE,
        @fechaSalida DATE,
        @usuario VARCHAR(20),
        @pc VARCHAR(20),
        @ip VARCHAR(20),
        @idEmpleado INT OUTPUT,
        @mensaje VARCHAR(500) OUTPUT
    AS
    BEGIN
        SET NOCOUNT ON;
        BEGIN TRY
            BEGIN TRANSACTION;

            -- Validar que la persona existe
            IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @idPersona AND activo = 1)
                BEGIN
                    SET @mensaje = 'La persona especificada no existe';
                    SET @idEmpleado = 0;
                    RETURN;
                END

            -- Validar que el tipo de empleado existe
            IF NOT EXISTS(SELECT 1 FROM TipoEmpleado WHERE id = @idTipoEmpleado AND activo = 1)
                BEGIN
                    SET @mensaje = 'El tipo de empleado especificado no existe';
                    SET @idEmpleado = 0;
                    RETURN;
                END

            -- Validar que la fecha de ingreso no sea futura
            IF @fechaIngreso > CAST(GETDATE() AS DATE)
                BEGIN
                    SET @mensaje = 'La fecha de ingreso no puede ser futura';
                    SET @idEmpleado = 0;
                    RETURN;
                END

            -- Validar que la fecha de salida sea posterior a la fecha de ingreso (si se proporciona)
            IF @fechaSalida IS NOT NULL AND @fechaSalida < @fechaIngreso
                BEGIN
                    SET @mensaje = 'La fecha de salida debe ser posterior a la fecha de ingreso';
                    SET @idEmpleado = 0;
                    RETURN;
                END

            -- Validar que no sea empleado duplicado
            IF EXISTS(SELECT 1 FROM Empleado WHERE idPersona = @idPersona AND activo = 1)
                BEGIN
                    SET @mensaje = 'Esta persona ya está registrada como empleado';
                    SET @idEmpleado = 0;
                    RETURN;
                END

            -- Insertar empleado
            INSERT INTO Empleado (
                idPersona, idTipoEmpleado, fechaIngreso, fechaSalida,
                usuario, pc, ip, fecha, activo
            )
            VALUES (
                       @idPersona, @idTipoEmpleado, @fechaIngreso, @fechaSalida,
                       @usuario, @pc, @ip, GETDATE(), 1
                   );

            SET @idEmpleado = SCOPE_IDENTITY();
            SET @mensaje = 'Empleado registrado exitosamente';

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @idEmpleado = 0;
            SET @mensaje = 'Inserción fallida';
        END CATCH
    END
GO

CREATE OR ALTER PROCEDURE paEmpleadoInsertar
    @idPersona INT,
    @idTipoEmpleado INT,
    @fechaIngreso DATE,
    @fechaSalida DATE,
    @idEmpleado INT OUTPUT,
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la persona existe
        IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @idPersona AND activo = 1)
            BEGIN
                SET @mensaje = 'La persona especificada no existe';
                SET @idEmpleado = 0;
                RETURN;
            END

        -- Validar que el tipo de empleado existe
        IF NOT EXISTS(SELECT 1 FROM TipoEmpleado WHERE id = @idTipoEmpleado AND activo = 1)
            BEGIN
                SET @mensaje = 'El tipo de empleado especificado no existe';
                SET @idEmpleado = 0;
                RETURN;
            END

        -- Validar que la fecha de ingreso no sea futura
        IF @fechaIngreso > CAST(GETDATE() AS DATE)
            BEGIN
                SET @mensaje = 'La fecha de ingreso no puede ser futura';
                SET @idEmpleado = 0;
                RETURN;
            END

        -- Validar que la fecha de salida sea posterior a la fecha de ingreso (si se proporciona)
        IF @fechaSalida IS NOT NULL AND @fechaSalida < @fechaIngreso
            BEGIN
                SET @mensaje = 'La fecha de salida debe ser posterior a la fecha de ingreso';
                SET @idEmpleado = 0;
                RETURN;
            END

        -- Validar que no sea empleado duplicado
        IF EXISTS(SELECT 1 FROM Empleado WHERE idPersona = @idPersona AND activo = 1)
            BEGIN
                SET @mensaje = 'Esta persona ya está registrada como empleado';
                SET @idEmpleado = 0;
                RETURN;
            END

        -- Insertar empleado
        INSERT INTO Empleado (
            idPersona, idTipoEmpleado, fechaIngreso, fechaSalida
        )
        VALUES (
                   @idPersona, @idTipoEmpleado, @fechaIngreso, @fechaSalida
               );

        SET @idEmpleado = SCOPE_IDENTITY();
        SET @mensaje = 'Empleado registrado exitosamente';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @idEmpleado = 0;
        SET @mensaje = 'Inserción fallida';
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE paEmpleadoActualizar
    @id INT,
    @idPersona INT,
    @idTipoEmpleado INT,
    @fechaIngreso DATE,
    @fechaSalida DATE,
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el empleado existe
        IF NOT EXISTS(SELECT 1 FROM Empleado WHERE id = @id AND activo = 1)
            BEGIN
                SET @mensaje = 'El empleado no existe o no está activo';
                RETURN;
            END

        -- Validar que la persona existe
        IF NOT EXISTS(SELECT 1 FROM Persona WHERE id = @idPersona AND activo = 1)
            BEGIN
                SET @mensaje = 'La persona especificada no existe';
                RETURN;
            END

        -- Validar que el tipo de empleado existe
        IF NOT EXISTS(SELECT 1 FROM TipoEmpleado WHERE id = @idTipoEmpleado AND activo = 1)
            BEGIN
                SET @mensaje = 'El tipo de empleado especificado no existe';
                RETURN;
            END

        -- Validar que la fecha de ingreso no sea futura
        IF @fechaIngreso > CAST(GETDATE() AS DATE)
            BEGIN
                SET @mensaje = 'La fecha de ingreso no puede ser futura';
                RETURN;
            END

        -- Validar que la fecha de salida sea posterior a la fecha de ingreso (si se proporciona)
        IF @fechaSalida IS NOT NULL AND @fechaSalida < @fechaIngreso
            BEGIN
                SET @mensaje = 'La fecha de salida debe ser posterior a la fecha de ingreso';
                RETURN;
            END

        -- Validar que no exista otro empleado con la misma persona
        IF EXISTS(SELECT 1 FROM Empleado
                  WHERE idPersona = @idPersona
                    AND id != @id
                    AND activo = 1)
            BEGIN
                SET @mensaje = 'Otra persona ya está registrada como empleado';
                RETURN;
            END

        -- Actualizar empleado
        UPDATE Empleado
        SET idPersona = @idPersona,
            idTipoEmpleado = @idTipoEmpleado,
            fechaIngreso = @fechaIngreso,
            fechaSalida = @fechaSalida
        WHERE id = @id;

        SET @mensaje = 'Empleado actualizado exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @mensaje = 'Actualización fallida';
    END CATCH
END
GO

-- Insertar TipoDocumento
CREATE OR ALTER PROCEDURE paTipoDocumentoInsertar
    @nombre VARCHAR(25),
    @abreviatura VARCHAR(5)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF EXISTS (SELECT 1 FROM TipoDocumento WHERE nombre = @nombre)
                BEGIN
                    RAISERROR('El tipo de documento ya existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM TipoDocumento WHERE abreviatura = @abreviatura)
                BEGIN
                    RAISERROR('La abreviatura ya existe', 16, 1);
                    RETURN -1;
                END

            INSERT INTO TipoDocumento (nombre, abreviatura)
            VALUES (@nombre, @abreviatura);

        COMMIT TRANSACTION
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- Actualizar TipoDocumento
CREATE OR ALTER PROCEDURE paTipoDocumentoActualizar
    @id INT,
    @nombre VARCHAR(25),
    @abreviatura VARCHAR(5)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF NOT EXISTS (SELECT 1 FROM TipoDocumento WHERE id = @id)
                BEGIN
                    RAISERROR('El tipo de documento no existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM TipoDocumento WHERE nombre = @nombre AND id != @id)
                BEGIN
                    RAISERROR('El tipo de documento ya existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM TipoDocumento WHERE abreviatura = @abreviatura AND id != @id)
                BEGIN
                    RAISERROR('La abreviatura ya existe', 16, 1);
                    RETURN -1;
                END

            UPDATE TipoDocumento
            SET nombre = @nombre,
                abreviatura = @abreviatura
            WHERE id = @id;

        COMMIT TRANSACTION
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO




-- Insertar TipoTelefono
CREATE OR ALTER PROCEDURE paTipoTelefonoInsertar
@nombre VARCHAR(25)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF EXISTS (SELECT 1 FROM TipoTelefono WHERE nombre = @nombre)
                BEGIN
                    RAISERROR('El tipo de teléfono ya existe', 16, 1);
                    RETURN -1;
                END

            INSERT INTO TipoTelefono (nombre)
            VALUES (@nombre);

        COMMIT TRANSACTION
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- Actualizar TipoTelefono
CREATE OR ALTER PROCEDURE paTipoTelefonoActualizar
    @id INT,
    @nombre VARCHAR(25)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF NOT EXISTS (SELECT 1 FROM TipoTelefono WHERE id = @id)
                BEGIN
                    RAISERROR('El tipo de teléfono no existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM TipoTelefono WHERE nombre = @nombre AND id != @id)
                BEGIN
                    RAISERROR('El tipo de teléfono ya existe', 16, 1);
                    RETURN -1;
                END

            UPDATE TipoTelefono
            SET nombre = @nombre
            WHERE id = @id;

        COMMIT TRANSACTION
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO




-- Insertar TipoEmpleado
CREATE OR ALTER PROCEDURE paTipoEmpleadoInsertar
@nombre VARCHAR(25)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF EXISTS (SELECT 1 FROM TipoEmpleado WHERE nombre = @nombre)
                BEGIN
                    RAISERROR('El tipo de empleado ya existe', 16, 1);
                    RETURN -1;
                END

            INSERT INTO TipoEmpleado (nombre)
            VALUES (@nombre);

        COMMIT TRANSACTION
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- Actualizar TipoEmpleado
CREATE OR ALTER PROCEDURE paTipoEmpleadoActualizar
    @id INT,
    @nombre VARCHAR(25)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF NOT EXISTS (SELECT 1 FROM TipoEmpleado WHERE id = @id)
                BEGIN
                    RAISERROR('El tipo de empleado no existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM TipoEmpleado WHERE nombre = @nombre AND id != @id)
                BEGIN
                    RAISERROR('El tipo de empleado ya existe', 16, 1);
                    RETURN -1;
                END

            UPDATE TipoEmpleado
            SET nombre = @nombre
            WHERE id = @id;

        COMMIT TRANSACTION
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO


/*--------------------------------------------------------------*/
/* 4. PROCEDIMIENTOS PARA TipoSaborProducto                     */
/*--------------------------------------------------------------*/

-- Insertar TipoSaborProducto
CREATE OR ALTER PROCEDURE paTipoSaborProductoInsertar
@nombre VARCHAR(25)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF EXISTS (SELECT 1 FROM TipoSaborProducto WHERE nombre = @nombre)
                BEGIN
                    RAISERROR('El tipo de sabor ya existe', 16, 1);
                    RETURN -1;
                END

            INSERT INTO TipoSaborProducto (nombre)
            VALUES (@nombre);

        COMMIT TRANSACTION
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- Actualizar TipoSaborProducto
CREATE OR ALTER PROCEDURE paTipoSaborProductoActualizar
    @id INT,
    @nombre VARCHAR(25)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF NOT EXISTS (SELECT 1 FROM TipoSaborProducto WHERE id = @id)
                BEGIN
                    RAISERROR('El tipo de sabor no existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM TipoSaborProducto WHERE nombre = @nombre AND id != @id)
                BEGIN
                    RAISERROR('El tipo de sabor ya existe', 16, 1);
                    RETURN -1;
                END

            UPDATE TipoSaborProducto
            SET nombre = @nombre
            WHERE id = @id;

        COMMIT TRANSACTION
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO




-- Insertar UnidadMedida
CREATE OR ALTER PROCEDURE paUnidadMedidaInsertar
    @nombre VARCHAR(25),
    @abreviatura VARCHAR(5)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF EXISTS (SELECT 1 FROM UnidadMedida WHERE nombre = @nombre)
                BEGIN
                    RAISERROR('La unidad de medida ya existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM UnidadMedida WHERE abreviatura = @abreviatura)
                BEGIN
                    RAISERROR('La abreviatura ya existe', 16, 1);
                    RETURN -1;
                END

            INSERT INTO UnidadMedida (nombre, abreviatura)
            VALUES (@nombre, @abreviatura);

        COMMIT TRANSACTION
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- Actualizar UnidadMedida
CREATE OR ALTER PROCEDURE paUnidadMedidaActualizar
    @id INT,
    @nombre VARCHAR(25),
    @abreviatura VARCHAR(5)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF NOT EXISTS (SELECT 1 FROM UnidadMedida WHERE id = @id)
                BEGIN
                    RAISERROR('La unidad de medida no existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM UnidadMedida WHERE nombre = @nombre AND id != @id)
                BEGIN
                    RAISERROR('La unidad de medida ya existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM UnidadMedida WHERE abreviatura = @abreviatura AND id != @id)
                BEGIN
                    RAISERROR('La abreviatura ya existe', 16, 1);
                    RETURN -1;
                END

            UPDATE UnidadMedida
            SET nombre = @nombre,
                abreviatura = @abreviatura
            WHERE id = @id;

        COMMIT TRANSACTION
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO




/*--------------------------------------------------------------*/
/* 6. PROCEDIMIENTOS PARA TipoOperacion                         */
/*--------------------------------------------------------------*/

-- Insertar TipoOperacion
CREATE OR ALTER PROCEDURE paTipoOperacionInsertar
@nombre VARCHAR(25)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF EXISTS (SELECT 1 FROM TipoOperacion WHERE nombre = @nombre)
                BEGIN
                    RAISERROR('El tipo de operación ya existe', 16, 1);
                    RETURN -1;
                END

            INSERT INTO TipoOperacion (nombre)
            VALUES (@nombre);

        COMMIT TRANSACTION
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- Actualizar TipoOperacion
CREATE OR ALTER PROCEDURE paTipoOperacionActualizar
    @id INT,
    @nombre VARCHAR(25)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF NOT EXISTS (SELECT 1 FROM TipoOperacion WHERE id = @id)
                BEGIN
                    RAISERROR('El tipo de operación no existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM TipoOperacion WHERE nombre = @nombre AND id != @id)
                BEGIN
                    RAISERROR('El tipo de operación ya existe', 16, 1);
                    RETURN -1;
                END

            UPDATE TipoOperacion
            SET nombre = @nombre
            WHERE id = @id;

        COMMIT TRANSACTION
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO




/*--------------------------------------------------------------*/
/* 7. PROCEDIMIENTOS PARA TipoComprobante                       */
/*--------------------------------------------------------------*/

-- Insertar TipoComprobante
CREATE OR ALTER PROCEDURE paTipoComprobanteInsertar
    @nombre VARCHAR(25),
    @abreviatura VARCHAR(5)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF EXISTS (SELECT 1 FROM TipoComprobante WHERE nombre = @nombre)
                BEGIN
                    RAISERROR('El tipo de comprobante ya existe', 16, 1);
                    RETURN -1;
                END

            INSERT INTO TipoComprobante (nombre, abreviatura)
            VALUES (@nombre, @abreviatura);

        COMMIT TRANSACTION
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- Actualizar TipoComprobante
CREATE OR ALTER PROCEDURE paTipoComprobanteActualizar
    @id INT,
    @nombre VARCHAR(25),
    @abreviatura VARCHAR(5)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF NOT EXISTS (SELECT 1 FROM TipoComprobante WHERE id = @id)
                BEGIN
                    RAISERROR('El tipo de comprobante no existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM TipoComprobante WHERE nombre = @nombre AND id != @id)
                BEGIN
                    RAISERROR('El tipo de comprobante ya existe', 16, 1);
                    RETURN -1;
                END

            UPDATE TipoComprobante
            SET nombre = @nombre,
                abreviatura = @abreviatura
            WHERE id = @id;

        COMMIT TRANSACTION
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO




/*--------------------------------------------------------------*/
/* 8. PROCEDIMIENTOS PARA TipoPago                              */
/*--------------------------------------------------------------*/

-- Insertar TipoPago
CREATE OR ALTER PROCEDURE paTipoPagoInsertar
    @nombre VARCHAR(25),
    @abreviatura VARCHAR(5)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF EXISTS (SELECT 1 FROM TipoPago WHERE nombre = @nombre)
                BEGIN
                    RAISERROR('El tipo de pago ya existe', 16, 1);
                    RETURN -1;
                END

            INSERT INTO TipoPago (nombre, abreviatura)
            VALUES (@nombre, @abreviatura);

        COMMIT TRANSACTION
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- Actualizar TipoPago
CREATE OR ALTER PROCEDURE paTipoPagoActualizar
    @id INT,
    @nombre VARCHAR(25),
    @abreviatura VARCHAR(5)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF NOT EXISTS (SELECT 1 FROM TipoPago WHERE id = @id)
                BEGIN
                    RAISERROR('El tipo de pago no existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM TipoPago WHERE nombre = @nombre AND id != @id)
                BEGIN
                    RAISERROR('El tipo de pago ya existe', 16, 1);
                    RETURN -1;
                END

            UPDATE TipoPago
            SET nombre = @nombre,
                abreviatura = @abreviatura
            WHERE id = @id;

        COMMIT TRANSACTION
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO




/*--------------------------------------------------------------*/
/* 9. PROCEDIMIENTOS PARA ConceptoPlanilla                      */
/*--------------------------------------------------------------*/

-- Insertar ConceptoPlanilla
CREATE OR ALTER PROCEDURE paConceptoPlanillaInsertar
    @nombre VARCHAR(50),
    @tipo CHAR(1) -- 'I' = Ingreso, 'D' = Descuento
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF @tipo NOT IN ('I', 'D')
                BEGIN
                    RAISERROR('El tipo debe ser I (Ingreso) o D (Descuento)', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM ConceptoPlanilla WHERE nombre = @nombre)
                BEGIN
                    RAISERROR('El concepto de planilla ya existe', 16, 1);
                    RETURN -1;
                END

            INSERT INTO ConceptoPlanilla (nombre, tipo)
            VALUES (@nombre, @tipo);

        COMMIT TRANSACTION
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- Actualizar ConceptoPlanilla
CREATE OR ALTER PROCEDURE paConceptoPlanillaActualizar
    @id INT,
    @nombre VARCHAR(50),
    @tipo CHAR(1)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            IF @tipo NOT IN ('I', 'D')
                BEGIN
                    RAISERROR('El tipo debe ser I (Ingreso) o D (Descuento)', 16, 1);
                    RETURN -1;
                END

            IF NOT EXISTS (SELECT 1 FROM ConceptoPlanilla WHERE id = @id)
                BEGIN
                    RAISERROR('El concepto de planilla no existe', 16, 1);
                    RETURN -1;
                END

            IF EXISTS (SELECT 1 FROM ConceptoPlanilla WHERE nombre = @nombre AND id != @id)
                BEGIN
                    RAISERROR('El concepto de planilla ya existe', 16, 1);
                    RETURN -1;
                END

            UPDATE ConceptoPlanilla
            SET nombre = @nombre,
                tipo = @tipo
            WHERE id = @id;

        COMMIT TRANSACTION
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO
CREATE PROCEDURE paProductoInsertar
    @nombre VARCHAR(50),
    @peso INT,
    @idUnidadMedida INT,
    @idTipoSaborProducto INT,
    @descripcion VARCHAR(200),
    @codigoBarra VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- VALIDACIONES
        IF LTRIM(RTRIM(@nombre)) = '' THROW 50001, 'El nombre del producto no puede estar vac�o.', 1;
        IF @peso <= 0 THROW 50002, 'El peso debe ser mayor a cero.', 1;
        IF @idUnidadMedida <= 0 THROW 50003, 'Debe seleccionar una unidad de medida v�lida.', 1;
        IF @idTipoSaborProducto <= 0 THROW 50004, 'Debe seleccionar un tipo de sabor v�lido.', 1;

        BEGIN TRANSACTION;

        INSERT INTO Producto(nombre, peso, idUnidadMedida, idTipoSaborProducto, descripcion, codigoBarra, activo, fecha)
        VALUES (@nombre, @peso, @idUnidadMedida, @idTipoSaborProducto, @descripcion, @codigoBarra, 1, GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- Actualizar Producto
-- =============================================
CREATE PROCEDURE paProductoActualizar
    @id INT,
    @nombre VARCHAR(50),
    @peso INT,
    @idUnidadMedida INT,
    @idTipoSaborProducto INT,
    @descripcion VARCHAR(200),
    @codigoBarra VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @id <= 0 THROW 50005, 'ID inv�lido.', 1;
        IF LTRIM(RTRIM(@nombre)) = '' THROW 50006, 'El nombre no puede estar vac�o.', 1;
        IF @peso <= 0 THROW 50007, 'El peso debe ser mayor que cero.', 1;

        BEGIN TRANSACTION;

        UPDATE Producto
        SET nombre = @nombre,
            peso = @peso,
            idUnidadMedida = @idUnidadMedida,
            idTipoSaborProducto = @idTipoSaborProducto,
            descripcion = @descripcion,
            codigoBarra = @codigoBarra,
            fechamod = GETDATE()
        WHERE id = @id;

        IF @@ROWCOUNT = 0 THROW 50008, 'No se encontr� el producto a actualizar.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- Insertar Materia Prima
-- =============================================
CREATE PROCEDURE paMateriaPrimaInsertar
    @nombre VARCHAR(50),
    @cantidad INT,
    @idUnidadMedida INT,
    @idProveedor INT,
    @fechaCompra DATE,
    @importe DECIMAL(10,2),
    @stockActual INT,
    @stockMinimo INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF LTRIM(RTRIM(@nombre)) = '' THROW 50010, 'El nombre de la materia prima es obligatorio.', 1;
        IF @cantidad < 0 THROW 50011, 'La cantidad no puede ser negativa.', 1;
        IF @importe < 0 THROW 50012, 'El importe debe ser positivo.', 1;
        IF @idUnidadMedida <= 0 THROW 50013, 'Unidad de medida inv�lida.', 1;
        IF @idProveedor <= 0 THROW 50014, 'Proveedor inv�lido.', 1;
        IF @stockActual < 0 THROW 50015, 'Stock actual no puede ser negativo.', 1;
        IF @stockMinimo < 0 THROW 50016, 'Stock m�nimo no puede ser negativo.', 1;

        BEGIN TRANSACTION;

        INSERT INTO MateriaPrima(nombre, cantidad, idUnidadMedida, idProveedor, fechaCompra, importe, stockActual, stockMinimo, activo, fecha)
        VALUES (@nombre, @cantidad, @idUnidadMedida, @idProveedor, @fechaCompra, @importe, @stockActual, @stockMinimo, 1, GETDATE());

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO


-- =============================================
-- Actualizar Materia Prima
-- =============================================

CREATE PROCEDURE paMateriaPrimaActualizar
    @id INT,
    @nombre VARCHAR(50),
    @cantidad INT,
    @idUnidadMedida INT,
    @idProveedor INT,
    @fechaCompra DATE,
    @importe DECIMAL(10,2),
    @stockActual INT,
    @stockMinimo INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @id <= 0 THROW 50017, 'ID inv�lido.', 1;
        IF LTRIM(RTRIM(@nombre)) = '' THROW 50018, 'El nombre no puede estar vac�o.', 1;
        IF @cantidad < 0 THROW 50019, 'La cantidad debe ser positiva.', 1;

        BEGIN TRANSACTION;

        UPDATE MateriaPrima
        SET nombre = @nombre,
            cantidad = @cantidad,
            idUnidadMedida = @idUnidadMedida,
            idProveedor = @idProveedor,
            fechaCompra = @fechaCompra,
            importe = @importe,
            stockActual = @stockActual,
            stockMinimo = @stockMinimo,
            fechamod = GETDATE()
        WHERE id = @id;

        IF @@ROWCOUNT = 0 THROW 50020, 'No se encontr� la materia prima para actualizar.', 1;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE paAlmacenInsertar
@direccion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF LTRIM(RTRIM(@direccion)) = '' THROW 50021, 'La direcci�n no puede estar vac�a.', 1;

        BEGIN TRANSACTION;

        INSERT INTO Almacen(direccion, activo, fecha)
        VALUES (@direccion, 1, GETDATE());

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO


-- =============================================
-- Actualizar Almacen
-- =============================================

CREATE PROCEDURE paAlmacenActualizar
    @id INT,
    @direccion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @id <= 0 THROW 50022, 'ID inv�lido.', 1;
        IF LTRIM(RTRIM(@direccion)) = '' THROW 50023, 'Direcci�n obligatoria.', 1;

        BEGIN TRANSACTION;

        UPDATE Almacen
        SET direccion = @direccion,
            fechamod = GETDATE()
        WHERE id = @id;

        IF @@ROWCOUNT = 0 THROW 50024, 'No se encontr� el almac�n para actualizar.', 1;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE paPrecioInsertar
    @idProducto INT,
    @cantidadMinima INT,
    @cantidadMaxima INT,
    @precio DECIMAL(10,2),
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- VALIDACIONES
        IF @idProducto <= 0 THROW 50060, 'ID de producto inv�lido.', 1;
        IF @cantidadMinima < 0 THROW 50061, 'Cantidad m�nima inv�lida.', 1;
        IF @cantidadMaxima < @cantidadMinima THROW 50062, 'Cantidad m�xima debe ser mayor o igual a la m�nima.', 1;
        IF @precio <= 0 THROW 50063, 'El precio debe ser mayor que cero.', 1;
        IF @fecha IS NULL THROW 50064, 'Debe especificar una fecha.', 1;

        BEGIN TRANSACTION;

        INSERT INTO Precio(idProducto, cantidadMinima, cantidadMaxima, precio, fecha, activo, fechaRegistro)
        VALUES (@idProducto, @cantidadMinima, @cantidadMaxima, @precio, @fecha, 1, GETDATE());

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- Actualizar Precio
-- =============================================

CREATE PROCEDURE paPrecioActualizar
    @id INT,
    @cantidadMinima INT,
    @cantidadMaxima INT,
    @precio DECIMAL(10,2),
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @id <= 0 THROW 50065, 'ID inv�lido.', 1;
        IF @cantidadMinima < 0 THROW 50066, 'Cantidad m�nima inv�lida.', 1;
        IF @cantidadMaxima < @cantidadMinima THROW 50067, 'Cantidad m�xima debe ser mayor o igual a la m�nima.', 1;
        IF @precio <= 0 THROW 50068, 'Precio inv�lido.', 1;
        IF @fecha IS NULL THROW 50069, 'Debe especificar una fecha v�lida.', 1;

        BEGIN TRANSACTION;

        UPDATE Precio
        SET cantidadMinima = @cantidadMinima,
            cantidadMaxima = @cantidadMaxima,
            precio = @precio,
            fecha = @fecha,
            fechamod = GETDATE()
        WHERE id = @id;

        IF @@ROWCOUNT = 0 THROW 50070, 'No se encontr� el registro de precio a actualizar.', 1;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE paAlmacenProductoInsertar
    @idAlmacen INT,
    @idProducto INT,
    @stockMinimo INT,
    @stockMaximo INT,
    @ubicacion VARCHAR(50),
    @usuario VARCHAR(20) -- Buena práctica: añadir quién lo registra
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validaciones
        IF @idAlmacen <= 0 THROW 50025, 'ID de almacén inválido.', 1;
        IF @idProducto <= 0 THROW 50026, 'ID de producto inválido.', 1;
        IF @stockMinimo < 0 THROW 50027, 'Stock mínimo no puede ser negativo.', 1;

        -- Validación de Stock Máximo (corregida)
        IF @stockMaximo IS NOT NULL AND @stockMaximo < @stockMinimo
            THROW 50028, 'El stock máximo debe ser mayor o igual al mínimo.', 1;

        -- Validación de duplicados
        IF EXISTS (SELECT 1 FROM AlmacenProducto WHERE idAlmacen = @idAlmacen AND idProducto = @idProducto)
            THROW 50029, 'Este producto ya está registrado en el almacén.', 1;

        BEGIN TRANSACTION;

        INSERT INTO AlmacenProducto(
            idAlmacen,
            idProducto,
            stockMinimo,
            stockMaximo,
            stock , -- El stock se inserta automáticamente como 0
            ubicacion,
            activo,
            fecha,
            usuario -- Añadido
        )
        VALUES (
                   @idAlmacen,
                   @idProducto,
                   @stockMinimo,
                   @stockMaximo,
                   0, -- <-- AQUÍ ESTÁ EL CAMBIO
                   @ubicacion,
                   1,
                   GETDATE(),
                   @usuario
               );

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- Actualizar AlmacenProducto
-- =============================================

CREATE PROCEDURE paAlmacenProductoActualizar
    @id INT,
    @idAlmacen INT,
    @idProducto INT,
    @stockMinimo INT,
    @stockMaximo INT,
    @stock INT,
    @ubicacion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- VALIDACIONES
        IF @id <= 0 THROW 50071, 'ID inv�lido.', 1;
        IF @idAlmacen <= 0 THROW 50072, 'Debe especificar un almac�n v�lido.', 1;
        IF @idProducto <= 0 THROW 50073, 'Debe especificar un producto v�lido.', 1;
        IF @stockMinimo < 0 THROW 50074, 'El stock m�nimo no puede ser negativo.', 1;
        IF @stockMaximo < @stockMinimo THROW 50075, 'El stock m�ximo debe ser mayor o igual al m�nimo.', 1;
        IF @stock < 0 THROW 50078, 'El stock no puede ser negativo.', 1;
        IF LTRIM(RTRIM(@ubicacion)) = '' THROW 50076, 'Debe indicar una ubicaci�n.', 1;

        BEGIN TRANSACTION;

        UPDATE AlmacenProducto
        SET idAlmacen = @idAlmacen,
            idProducto = @idProducto,
            stockMinimo = @stockMinimo,
            stockMaximo = @stockMaximo,
            stock = @stock,
            ubicacion = @ubicacion
        WHERE id = @id;

        IF @@ROWCOUNT = 0 THROW 50077, 'No se encontr� el registro de AlmacenProducto a actualizar.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- Insertar AlmacenMateriaPrima
-- =============================================

CREATE PROCEDURE paAlmacenMateriaPrimaInsertar
    @idAlmacen INT,
    @idMateriaPrima INT,
    @stockMinimo INT,
    @stockMaximo INT,
    @ubicacion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- VALIDACIONES
        IF @idAlmacen <= 0 THROW 50030, 'ID de almac�n inv�lido.', 1;
        IF @idMateriaPrima <= 0 THROW 50031, 'ID de materia prima inv�lido.', 1;
        IF @stockMinimo < 0 THROW 50032, 'El stock m�nimo no puede ser negativo.', 1;
        IF @stockMaximo < @stockMinimo THROW 50033, 'El stock m�ximo debe ser mayor o igual al m�nimo.', 1;

        BEGIN TRANSACTION;

        INSERT INTO AlmacenMateriaPrima(idAlmacen, idMateriaPrima, stockMinimo, stockMaximo, stock , ubicacion, activo, fecha)
        VALUES (@idAlmacen, @idMateriaPrima, @stockMinimo, @stockMaximo, 0 ,@ubicacion, 1, GETDATE());

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- Actualizar AlmacenMateriaPrima
-- =============================================

CREATE PROCEDURE paAlmacenMateriaPrimaActualizar
    @id INT,
    @stockMinimo INT,
    @stockMaximo INT,
    @stock INT,
    @ubicacion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @id <= 0 THROW 50034, 'ID inv�lido.', 1;
        IF @stockMinimo < 0 THROW 50035, 'El stock m�nimo no puede ser negativo.', 1;
        IF @stockMaximo < @stockMinimo THROW 50036, 'El stock m�ximo debe ser mayor o igual al m�nimo.', 1;
        IF @stock < 0 THROW 50080, 'El stock no puede ser negativo.', 1;

        BEGIN TRANSACTION;

        UPDATE AlmacenMateriaPrima
        SET stockMinimo = @stockMinimo,
            stockMaximo = @stockMaximo,
            stock = @stock,
            ubicacion = @ubicacion,
            fechamod = GETDATE()
        WHERE id = @id;

        IF @@ROWCOUNT = 0 THROW 50037, 'No se encontr� el registro a actualizar.', 1;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO




CREATE PROCEDURE paKardexInsertar
    @idAlmacen INT,
    @idProducto INT,
    @cantidad INT,
    @tipoMovimiento CHAR(1),
    @idtipoOperacion INT,
    @fecha DATE,
    @msgError VARCHAR(200) OUTPUT

AS
BEGIN
    SET NOCOUNT ON;
    IF @idAlmacen IS NULL OR @idAlmacen <= 0
        THROW 50030, 'El ID de almacén es obligatorio.', 1;
    IF @idProducto IS NULL OR @idProducto <= 0
        THROW 50031, 'El ID de producto es obligatorio.', 1;
    IF @cantidad IS NULL OR @cantidad <= 0
        THROW 50032, 'La cantidad debe ser mayor a cero.', 1;
    IF @tipoMovimiento NOT IN ('E', 'S')
        THROW 50033, 'El tipo de movimiento es inválido. Debe ser E (Entrada) o S (Salida).', 1;
    IF @idtipoOperacion IS NULL OR @idtipoOperacion <= 0
        THROW 50034, 'El tipo de operación es obligatorio.', 1;
    IF @fecha IS NULL
        SET @fecha = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @tipoMovimiento = 'S'
            BEGIN
                DECLARE @stockActual INT;
                SELECT @stockActual = ISNULL(stock, 0)
                FROM AlmacenProducto WITH (UPDLOCK, HOLDLOCK)
                WHERE idAlmacen = @idAlmacen AND idProducto = @idProducto;

                IF @stockActual IS NULL
                    BEGIN
                        THROW 50035, 'El producto no existe en el almacén especificado.', 1;
                    END

                IF @stockActual < @cantidad
                    BEGIN

                        SET @msgError = CONCAT('Stock insuficiente para el producto. Stock actual: ', @stockActual, ', Cantidad solicitada: ', @cantidad, '.');

                        THROW 50036, @msgError, 1;
                    END
            END

        DECLARE @anio INT = YEAR(@fecha);
        DECLARE @mes INT = MONTH(@fecha);

        INSERT INTO dbo.Kardex (
            idAlmacen,
            idProducto,
            cantidad,
            tipoMovimiento,
            idtipoOperacion,
            fecha,
            anio,
            mes,
            activo
        )
        VALUES (
                   @idAlmacen,
                   @idProducto,
                   @cantidad,
                   @tipoMovimiento,
                   @idtipoOperacion,
                   @fecha,
                   @anio,
                   @mes,
                   1
               );


        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
CREATE OR ALTER PROCEDURE paProduccionInsertar
    @idProducto INT,
    @fechaProduccion DATE,
    @cantidad INT,
    @lote VARCHAR(20),
    @idProduccion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto)
            BEGIN
                RAISERROR('El producto no existe', 16, 1);
                RETURN;
            END

        INSERT INTO Produccion (
            idProducto, fechaProduccion, cantidad, lote
        )
        VALUES (
                   @idProducto, @fechaProduccion, @cantidad, @lote
               );

        SET @idProduccion = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        SELECT @idProduccion AS id, 'Produccion registrada exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Actualizar Produccion
CREATE OR ALTER PROCEDURE paProduccionActualizar
    @id INT,
    @idProducto INT,
    @fechaProduccion DATE,
    @cantidad INT,
    @lote VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Produccion WHERE id = @id)
            BEGIN
                RAISERROR('La produccion no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto)
            BEGIN
                RAISERROR('El producto no existe', 16, 1);
                RETURN;
            END

        UPDATE Produccion
        SET idProducto = @idProducto,
            fechaProduccion = @fechaProduccion,
            cantidad = @cantidad,
            lote = @lote
        WHERE id = @id;

        COMMIT TRANSACTION;
        SELECT 'Produccion actualizada exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Insertar Produccion Producto
CREATE OR ALTER PROCEDURE paProduccionProductoInsertar
    @idProduccion INT,
    @idProducto INT,
    @cantidad INT,
    @fechaVencimiento DATE,
    @idProduccionProducto INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Produccion WHERE id = @idProduccion)
            BEGIN
                RAISERROR('La produccion no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto)
            BEGIN
                RAISERROR('El producto no existe', 16, 1);
                RETURN;
            END

        INSERT INTO ProduccionProducto (
            idProduccion, idProducto, cantidad, fechaVencimiento
        )
        VALUES (
                   @idProduccion, @idProducto, @cantidad, @fechaVencimiento
               );

        SET @idProduccionProducto = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        SELECT @idProduccionProducto AS id, 'Produccion-Producto registrado exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Actualizar Produccion Producto
CREATE OR ALTER PROCEDURE paProduccionProductoActualizar
    @id INT,
    @idProduccion INT,
    @idProducto INT,
    @cantidad INT,
    @fechaVencimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM ProduccionProducto WHERE id = @id)
            BEGIN
                RAISERROR('El registro no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM Produccion WHERE id = @idProduccion)
            BEGIN
                RAISERROR('La produccion no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto)
            BEGIN
                RAISERROR('El producto no existe', 16, 1);
                RETURN;
            END

        UPDATE ProduccionProducto
        SET idProduccion = @idProduccion,
            idProducto = @idProducto,
            cantidad = @cantidad,
            fechaVencimiento = @fechaVencimiento
        WHERE id = @id;

        COMMIT TRANSACTION;
        SELECT 'Produccion-Producto actualizado exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Insertar Materia Prima Produccion
CREATE OR ALTER PROCEDURE paMateriaPrimaProduccionInsertar
    @idMateriaPrima INT,
    @idProduccion INT,
    @cantidad INT,
    @idMateriaPrimaProduccion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM MateriaPrima WHERE id = @idMateriaPrima)
            BEGIN
                RAISERROR('La materia prima no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM Produccion WHERE id = @idProduccion)
            BEGIN
                RAISERROR('La produccion no existe', 16, 1);
                RETURN;
            END

        INSERT INTO MateriaPrimaProduccion (
            idMateriaPrima, idProduccion, cantidad
        )
        VALUES (
                   @idMateriaPrima, @idProduccion, @cantidad
               );

        SET @idMateriaPrimaProduccion = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        SELECT @idMateriaPrimaProduccion AS id, 'Materia Prima-Produccion registrada exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Actualizar Materia Prima Produccion
CREATE OR ALTER PROCEDURE paMateriaPrimaProduccionActualizar
    @id INT,
    @idMateriaPrima INT,
    @idProduccion INT,
    @cantidad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM MateriaPrimaProduccion WHERE id = @id)
            BEGIN
                RAISERROR('El registro no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM MateriaPrima WHERE id = @idMateriaPrima)
            BEGIN
                RAISERROR('La materia prima no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM Produccion WHERE id = @idProduccion)
            BEGIN
                RAISERROR('La produccion no existe', 16, 1);
                RETURN;
            END

        UPDATE MateriaPrimaProduccion
        SET idMateriaPrima = @idMateriaPrima,
            idProduccion = @idProduccion,
            cantidad = @cantidad
        WHERE id = @id;

        COMMIT TRANSACTION;
        SELECT 'Materia Prima-Produccion actualizada exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
-- Insertar Pedido Cabecera
CREATE OR ALTER PROCEDURE paPedidoCabInsertar
    @idCliente INT,
    @fechaPedido DATE,
    @fechaEntrega DATE = NULL,
    @estado VARCHAR(20) = 'PENDIENTE',
    @idPedidoCab INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id = @idCliente)
            BEGIN
                RAISERROR('El cliente no existe', 16, 1);
                RETURN;
            END

        INSERT INTO PedidoCab (
            idCliente, fechaPedido, fechaEntrega, estado
        )
        VALUES (
                   @idCliente, @fechaPedido, @fechaEntrega, @estado
               );

        SET @idPedidoCab = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        SELECT @idPedidoCab AS id, 'Pedido registrado exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Actualizar Pedido Cabecera
CREATE OR ALTER PROCEDURE paPedidoCabActualizar
    @id INT,
    @idCliente INT,
    @fechaPedido DATE,
    @fechaEntrega DATE = NULL,
    @estado VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM PedidoCab WHERE id = @id)
            BEGIN
                RAISERROR('El pedido no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id = @idCliente)
            BEGIN
                RAISERROR('El cliente no existe', 16, 1);
                RETURN;
            END

        UPDATE PedidoCab
        SET idCliente = @idCliente,
            fechaPedido = @fechaPedido,
            fechaEntrega = @fechaEntrega,
            estado = @estado
        WHERE id = @id;

        COMMIT TRANSACTION;
        SELECT 'Pedido actualizado exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Insertar Pedido Detalle
CREATE OR ALTER PROCEDURE paPedidoDetInsertar
    @idPedidoCab INT,
    @idProducto INT,
    @cantidad INT,
    @precio DECIMAL(10,2),
    @idPromocion INT,
    @idPedidoDet INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @porcentajeIGV DECIMAL(5,2);

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM PedidoCab WHERE id = @idPedidoCab)
            BEGIN
                RAISERROR('El pedido no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto)
            BEGIN
                RAISERROR('El producto no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS(SELECT 1 FROM Promocion WHERE id = @idPromocion)
            BEGIN
                RAISERROR('La promocion no existe', 16, 1);
                RETURN;
            END

        -- Obtener IGV vigente desde Parametro
        SELECT TOP 1 @porcentajeIGV = CAST(valor AS DECIMAL(5,2))
        FROM Parametro
        WHERE codigo = 'IGV'
          AND fechaVigencia <= CAST(GETDATE() AS DATE)
          AND (fechaFinVigencia IS NULL OR fechaFinVigencia >= CAST(GETDATE() AS DATE))
          AND activo = 1
        ORDER BY fechaVigencia DESC;

        -- Si no encuentra, usar 18% por defecto
        SET @porcentajeIGV = ISNULL(@porcentajeIGV, 18.00);

        INSERT INTO PedidoDet (
            idPedidoCab, idProducto, cantidad, precio, idPromocion, porcentajeIGV
        )
        VALUES (
                   @idPedidoCab, @idProducto, @cantidad, @precio, @idPromocion, @porcentajeIGV
               );

        SET @idPedidoDet = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        SELECT @idPedidoDet AS id, 'Detalle de pedido registrado exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Actualizar Pedido Detalle
CREATE OR ALTER PROCEDURE paPedidoDetActualizar
    @id INT,
    @idPedidoCab INT,
    @idProducto INT,
    @cantidad INT,
    @precio DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM PedidoDet WHERE id = @id)
            BEGIN
                RAISERROR('El detalle del pedido no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM PedidoCab WHERE id = @idPedidoCab)
            BEGIN
                RAISERROR('El pedido no existe', 16, 1);
                RETURN;
            END

        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto)
            BEGIN
                RAISERROR('El producto no existe', 16, 1);
                RETURN;
            END

        UPDATE PedidoDet
        SET idPedidoCab = @idPedidoCab,
            idProducto = @idProducto,
            cantidad = @cantidad,
            precio = @precio
        WHERE id = @id;

        COMMIT TRANSACTION;
        SELECT 'Detalle de pedido actualizado exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
CREATE PROCEDURE paKardexActualizar
    @id INT,
    @cantidad INT,
    @tipoMovimiento CHAR(1),
    @idTipoOperacion INT,
    @fecha DATE,
    @anio INT,
    @mes INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @id <= 0 THROW 50047, 'ID de Kardex inv�lido.', 1;
        IF @cantidad <= 0 THROW 50048, 'Cantidad inv�lida.', 1;
        IF @tipoMovimiento NOT IN ('E','S') THROW 50049, 'Tipo de movimiento inv�lido.', 1;
        IF @idTipoOperacion <= 0 THROW 50050, 'Tipo de operaci�n inv�lido.', 1;
        IF @anio < 2000 THROW 50051, 'A�o inv�lido.', 1;
        IF @mes NOT BETWEEN 1 AND 12 THROW 50052, 'Mes inv�lido.', 1;

        BEGIN TRANSACTION;

        UPDATE Kardex
        SET cantidad = @cantidad,
            tipoMovimiento = @tipoMovimiento,
            idTipoOperacion = @idTipoOperacion,
            fecha = @fecha,
            anio = @anio,
            mes = @mes,
            fechamod = GETDATE()
        WHERE id = @id;

        IF @@ROWCOUNT = 0 THROW 50053, 'No se encontr� el registro Kardex a actualizar.', 1;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO
-- =============================================
-- Insertar Precio
-- =============================================


CREATE PROCEDURE paKardexInsertar
    @idAlmacen INT,
    @idProducto INT,
    @cantidad INT,
    @tipoMovimiento CHAR(1),                 -- 'E' = Entrada, 'S' = Salida
    @idTipoOperacion INT,
    @fecha DATE,
    @mes INT,
    @anio INT,
    @resultado INT OUTPUT,                   -- 1 = Éxito, 0 = Error
    @mensaje VARCHAR(200) OUTPUT,
    @idGenerado INT OUTPUT                   -- ID del registro insertado
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @stockActual INT = 0;
        DECLARE @stockMinimo INT = 0;

        -- Validaciones básicas
        IF @idAlmacen IS NULL OR @idAlmacen <= 0
            BEGIN SET @resultado = 0; SET @mensaje = 'Almacén inválido'; ROLLBACK TRANSACTION; RETURN; END

        IF @idProducto IS NULL OR @idProducto <= 0
            BEGIN SET @resultado = 0; SET @mensaje = 'Producto inválido'; ROLLBACK TRANSACTION; RETURN; END

        IF @cantidad IS NULL OR @cantidad <= 0
            BEGIN SET @resultado = 0; SET @mensaje = 'Cantidad debe ser mayor a 0'; ROLLBACK TRANSACTION; RETURN; END

        IF @tipoMovimiento NOT IN ('E','S')
            BEGIN SET @resultado = 0; SET @mensaje = 'Tipo de movimiento debe ser E (Entrada) o S (Salida)'; ROLLBACK TRANSACTION; RETURN; END

        IF @mes IS NULL OR @mes NOT BETWEEN 1 AND 12
            BEGIN SET @resultado = 0; SET @mensaje = 'Mes debe estar entre 1 y 12'; ROLLBACK TRANSACTION; RETURN; END

        IF @anio IS NULL OR @anio < 2000
            BEGIN SET @resultado = 0; SET @mensaje = 'Año inválido'; ROLLBACK TRANSACTION; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM Almacen WHERE id = @idAlmacen AND activo = 1)
            BEGIN SET @resultado = 0; SET @mensaje = 'El almacén especificado no existe'; ROLLBACK TRANSACTION; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto AND activo = 1)
            BEGIN SET @resultado = 0; SET @mensaje = 'El producto especificado no existe'; ROLLBACK TRANSACTION; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM TipoOperacion WHERE id = @idTipoOperacion AND activo = 1)
            BEGIN SET @resultado = 0; SET @mensaje = 'El tipo de operación especificado no existe'; ROLLBACK TRANSACTION; RETURN; END

        -- Validación de stock para salidas
        IF @tipoMovimiento = 'S'
            BEGIN
                SELECT @stockActual = ISNULL(SUM(
                                                     CASE WHEN tipoMovimiento = 'E' THEN cantidad WHEN tipoMovimiento = 'S' THEN -cantidad END
                                             ), 0)
                FROM Kardex
                WHERE idAlmacen = @idAlmacen AND idProducto = @idProducto AND activo = 1;

                IF @stockActual < @cantidad
                    BEGIN
                        SET @resultado = 0;
                        SET @mensaje = 'Stock insuficiente. Stock actual: ' + CAST(@stockActual AS VARCHAR) +
                                       ', Cantidad solicitada: ' + CAST(@cantidad AS VARCHAR);
                        ROLLBACK TRANSACTION;
                        RETURN;
                    END

                SELECT @stockMinimo = ISNULL(stockMinimo, 0)
                FROM AlmacenProducto
                WHERE idAlmacen = @idAlmacen AND idProducto = @idProducto AND activo = 1;

                IF (@stockActual - @cantidad) < @stockMinimo
                    SET @mensaje = 'ADVERTENCIA: Stock quedará por debajo del mínimo (' + CAST(@stockMinimo AS VARCHAR) + ' unidades). ';
                ELSE
                    SET @mensaje = '';
            END
        ELSE
            SET @mensaje = '';

        -- Insertar
        INSERT INTO Kardex (
            idAlmacen, idProducto, cantidad, tipoMovimiento,
            idTipoOperacion, fecha, mes, anio
        )
        VALUES (
                   @idAlmacen, @idProducto, @cantidad, @tipoMovimiento,
                   @idTipoOperacion, @fecha, @mes, @anio
               );

        SET @idGenerado = SCOPE_IDENTITY();
        SET @resultado = 1;

        IF @tipoMovimiento = 'E'
            SET @mensaje = @mensaje + 'Entrada registrada exitosamente';
        ELSE
            SET @mensaje = @mensaje + 'Salida registrada exitosamente';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
        SET @idGenerado = NULL;
    END CATCH
END
GO

CREATE PROCEDURE paKardexActualizar
    @id INT,                                  -- ID del registro a actualizar
    @idAlmacen INT,
    @idProducto INT,
    @cantidad INT,
    @tipoMovimiento CHAR(1),                 -- 'E' = Entrada, 'S' = Salida
    @idTipoOperacion INT,
    @fecha DATE,
    @mes INT,
    @anio INT,
    @resultado INT OUTPUT,                   -- 1 = Éxito, 0 = Error
    @mensaje VARCHAR(200) OUTPUT,
    @idGenerado INT OUTPUT                   -- ID del registro actualizado
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @stockActual INT = 0;
        DECLARE @stockMinimo INT = 0;

        IF @id IS NULL OR @id <= 0
            BEGIN SET @resultado = 0; SET @mensaje = 'ID inválido'; ROLLBACK TRANSACTION; RETURN; END

        IF @idAlmacen IS NULL OR @idAlmacen <= 0
            BEGIN SET @resultado = 0; SET @mensaje = 'Almacén inválido'; ROLLBACK TRANSACTION; RETURN; END

        IF @idProducto IS NULL OR @idProducto <= 0
            BEGIN SET @resultado = 0; SET @mensaje = 'Producto inválido'; ROLLBACK TRANSACTION; RETURN; END

        IF @cantidad IS NULL OR @cantidad <= 0
            BEGIN SET @resultado = 0; SET @mensaje = 'Cantidad debe ser mayor a 0'; ROLLBACK TRANSACTION; RETURN; END

        IF @tipoMovimiento NOT IN ('E','S')
            BEGIN SET @resultado = 0; SET @mensaje = 'Tipo de movimiento debe ser E (Entrada) o S (Salida)'; ROLLBACK TRANSACTION; RETURN; END

        IF @mes IS NULL OR @mes NOT BETWEEN 1 AND 12
            BEGIN SET @resultado = 0; SET @mensaje = 'Mes debe estar entre 1 y 12'; ROLLBACK TRANSACTION; RETURN; END

        IF @anio IS NULL OR @anio < 2000
            BEGIN SET @resultado = 0; SET @mensaje = 'Año inválido'; ROLLBACK TRANSACTION; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM Kardex WHERE id = @id AND activo = 1)
            BEGIN SET @resultado = 0; SET @mensaje = 'Movimiento de Kardex no encontrado'; ROLLBACK TRANSACTION; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM Almacen WHERE id = @idAlmacen AND activo = 1)
            BEGIN SET @resultado = 0; SET @mensaje = 'El almacén especificado no existe'; ROLLBACK TRANSACTION; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto AND activo = 1)
            BEGIN SET @resultado = 0; SET @mensaje = 'El producto especificado no existe'; ROLLBACK TRANSACTION; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM TipoOperacion WHERE id = @idTipoOperacion AND activo = 1)
            BEGIN SET @resultado = 0; SET @mensaje = 'El tipo de operación especificado no existe'; ROLLBACK TRANSACTION; RETURN; END

        -- Obtener datos anteriores
        DECLARE @tipoMovimientoAnterior CHAR(1);
        DECLARE @cantidadAnterior INT;

        SELECT @tipoMovimientoAnterior = tipoMovimiento, @cantidadAnterior = cantidad
        FROM Kardex
        WHERE id = @id;

        -- Calcular stock actual excluyendo el registro que se va a actualizar
        SELECT @stockActual = ISNULL(SUM(
                                             CASE WHEN tipoMovimiento = 'E' THEN cantidad WHEN tipoMovimiento = 'S' THEN -cantidad END
                                     ), 0)
        FROM Kardex
        WHERE idAlmacen = @idAlmacen AND idProducto = @idProducto AND activo = 1 AND id != @id;

        -- Validación de stock si el nuevo movimiento es salida
        IF @tipoMovimiento = 'S'
            BEGIN
                IF @stockActual < @cantidad
                    BEGIN
                        SET @resultado = 0;
                        SET @mensaje = 'Stock insuficiente. Stock actual disponible: ' + CAST(@stockActual AS VARCHAR) +
                                       ', Cantidad solicitada: ' + CAST(@cantidad AS VARCHAR);
                        ROLLBACK TRANSACTION;
                        RETURN;
                    END

                SELECT @stockMinimo = ISNULL(stockMinimo, 0)
                FROM AlmacenProducto
                WHERE idAlmacen = @idAlmacen AND idProducto = @idProducto AND activo = 1;

                IF (@stockActual - @cantidad) < @stockMinimo
                    SET @mensaje = 'ADVERTENCIA: Stock quedará por debajo del mínimo (' + CAST(@stockMinimo AS VARCHAR) + ' unidades). ';
                ELSE
                    SET @mensaje = '';
            END
        ELSE
            SET @mensaje = '';

        -- Actualizar registro
        UPDATE Kardex SET
                          idAlmacen = @idAlmacen,
                          idProducto = @idProducto,
                          cantidad = @cantidad,
                          tipoMovimiento = @tipoMovimiento,
                          idTipoOperacion = @idTipoOperacion,
                          fecha = @fecha,
                          mes = @mes,
                          anio = @anio
        WHERE id = @id;

        SET @idGenerado = @id;
        SET @resultado = 1;
        SET @mensaje = @mensaje + 'Movimiento de Kardex actualizado exitosamente';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
        SET @idGenerado = NULL;
    END CATCH
END
GO
CREATE PROCEDURE paComprobanteInsertar
    @idTipoComprobante INT,
    @serie CHAR(4),
    @correlativo INT,
    @fechaEmision DATE,
    @subtotal DECIMAL(10,2),
    @porcentajeIGV DECIMAL(5,2),
    @igv DECIMAL(10,2),
    @total DECIMAL(10,2),
    @resultado INT OUTPUT,
    @mensaje VARCHAR(200) OUTPUT,
    @idGenerado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @idTipoComprobante IS NULL OR @idTipoComprobante <= 0
            BEGIN SET @resultado=0; SET @mensaje='Tipo de comprobante inválido'; ROLLBACK TRANSACTION; RETURN; END
        IF @serie IS NULL OR LEN(@serie) != 4
            BEGIN SET @resultado=0; SET @mensaje='Serie debe tener 4 caracteres'; ROLLBACK TRANSACTION; RETURN; END
        IF @correlativo IS NULL OR @correlativo <= 0
            BEGIN SET @resultado=0; SET @mensaje='Correlativo debe ser mayor a 0'; ROLLBACK TRANSACTION; RETURN; END
        IF EXISTS (SELECT 1 FROM Comprobante WHERE serie = @serie AND correlativo = @correlativo AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='Ya existe un comprobante con esta serie y correlativo'; ROLLBACK TRANSACTION; RETURN; END

        INSERT INTO Comprobante (
            idTipoComprobante, serie, correlativo, fechaEmision,
            subtotal, porcentajeIGV, igv, total

        )
        VALUES (
                   @idTipoComprobante, @serie, @correlativo, @fechaEmision,
                   @subtotal, @porcentajeIGV, @igv, @total

               );

        SET @idGenerado = SCOPE_IDENTITY();
        SET @resultado = 1;
        SET @mensaje = 'Comprobante creado exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
        SET @idGenerado = NULL;
    END CATCH
END
GO

CREATE PROCEDURE paComprobanteActualizar
    @id INT,
    @idTipoComprobante INT,
    @serie CHAR(4),
    @correlativo INT,
    @fechaEmision DATE,
    @subtotal DECIMAL(10,2),
    @porcentajeIGV DECIMAL(5,2),
    @igv DECIMAL(10,2),
    @total DECIMAL(10,2),
    @resultado INT OUTPUT,
    @mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM Comprobante WHERE id = @id AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='Comprobante no encontrado'; ROLLBACK TRANSACTION; RETURN; END
        IF EXISTS (SELECT 1 FROM Comprobante WHERE serie = @serie AND correlativo = @correlativo AND id != @id AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='Ya existe otro comprobante con esta serie y correlativo'; ROLLBACK TRANSACTION; RETURN; END

        UPDATE Comprobante SET
                               idTipoComprobante = @idTipoComprobante,
                               serie = @serie,
                               correlativo = @correlativo,
                               fechaEmision = @fechaEmision,
                               subtotal = @subtotal,
                               porcentajeIGV = @porcentajeIGV,
                               igv = @igv,
                               total = @total
        WHERE id = @id;

        SET @resultado = 1;
        SET @mensaje = 'Comprobante actualizado exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- ========================================
-- PROCEDIMIENTOS SEPARADOS: VentaCab (Insert / Update)
-- ========================================
CREATE PROCEDURE paVentaCabInsertar
    @idComprobante INT,
    @idEmpleado INT,
    @idCliente INT,
    @fechaVenta DATE,
    @estado VARCHAR(20) = 'PENDIENTE',
    @resultado INT OUTPUT,
    @mensaje VARCHAR(200) OUTPUT,
    @idGenerado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @idComprobante IS NULL OR @idComprobante <= 0
            BEGIN SET @resultado=0; SET @mensaje='Comprobante inválido'; ROLLBACK TRANSACTION; RETURN; END
        IF @idEmpleado IS NULL OR @idEmpleado <= 0
            BEGIN SET @resultado=0; SET @mensaje='Empleado inválido'; ROLLBACK TRANSACTION; RETURN; END
        IF @idCliente IS NULL OR @idCliente <= 0
            BEGIN SET @resultado=0; SET @mensaje='Cliente inválido'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM Comprobante WHERE id = @idComprobante AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='El comprobante especificado no existe'; ROLLBACK TRANSACTION; RETURN; END
        IF EXISTS (SELECT 1 FROM VentaCab WHERE idComprobante = @idComprobante AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='El comprobante ya está asociado a otra venta'; ROLLBACK TRANSACTION; RETURN; END

        INSERT INTO VentaCab (
            idComprobante, idEmpleado, idCliente, fechaVenta, estado
        )
        VALUES (
                   @idComprobante, @idEmpleado, @idCliente, @fechaVenta, @estado
               );

        SET @idGenerado = SCOPE_IDENTITY();
        SET @resultado = 1;
        SET @mensaje = 'Venta creada exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
        SET @idGenerado = NULL;
    END CATCH
END
GO

CREATE PROCEDURE paVentaCabActualizar
    @id INT,
    @idComprobante INT,
    @idEmpleado INT,
    @idCliente INT,
    @fechaVenta DATE,
    @estado VARCHAR(20),
    @resultado INT OUTPUT,
    @mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM VentaCab WHERE id = @id AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='Venta no encontrada'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM Comprobante WHERE id = @idComprobante AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='El comprobante especificado no existe'; ROLLBACK TRANSACTION; RETURN; END
        IF EXISTS (SELECT 1 FROM VentaCab WHERE idComprobante = @idComprobante AND id != @id AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='El comprobante ya está asociado a otra venta'; ROLLBACK TRANSACTION; RETURN; END

        UPDATE VentaCab SET
                            idComprobante = @idComprobante,
                            idEmpleado = @idEmpleado,
                            idCliente = @idCliente,
                            fechaVenta = @fechaVenta,
                            estado = @estado,
                            fechamod = GETDATE()
        WHERE id = @id;

        SET @resultado = 1;
        SET @mensaje = 'Venta actualizada exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- ========================================
-- PROCEDIMIENTOS SEPARADOS: VentaDet (Insert / Update)
-- ========================================
CREATE PROCEDURE paVentaDetInsertar
    @idVentaCab INT,
    @idProducto INT,
    @cantidad INT,
    @precio DECIMAL(10,2),
    @resultado INT OUTPUT,
    @mensaje VARCHAR(200) OUTPUT,
    @idGenerado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @idPromocion INT = NULL;
        DECLARE @porcentajeDescuento DECIMAL(5,2) = 0;
        DECLARE @porcentajeIGV DECIMAL(5,2);
        DECLARE @monto DECIMAL(10,2) = @cantidad * @precio;

        IF @idVentaCab IS NULL OR @idVentaCab <= 0
            BEGIN SET @resultado=0; SET @mensaje='Venta cabecera inválida'; ROLLBACK TRANSACTION; RETURN; END
        IF @idProducto IS NULL OR @idProducto <= 0
            BEGIN SET @resultado=0; SET @mensaje='Producto inválido'; ROLLBACK TRANSACTION; RETURN; END
        IF @cantidad IS NULL OR @cantidad <= 0
            BEGIN SET @resultado=0; SET @mensaje='Cantidad debe ser mayor a 0'; ROLLBACK TRANSACTION; RETURN; END
        IF @precio IS NULL OR @precio <= 0
            BEGIN SET @resultado=0; SET @mensaje='Precio debe ser mayor a 0'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM VentaCab WHERE id = @idVentaCab AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='La venta cabecera no existe'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='El producto no existe'; ROLLBACK TRANSACTION; RETURN; END

        SELECT TOP 1 @porcentajeIGV = CAST(valor AS DECIMAL(5,2))
        FROM Parametro
        WHERE codigo = 'IGV'
          AND fechaVigencia <= CAST(GETDATE() AS DATE)
          AND (fechaFinVigencia IS NULL OR fechaFinVigencia >= CAST(GETDATE() AS DATE))
          AND activo = 1
        ORDER BY fechaVigencia DESC;
        SET @porcentajeIGV = ISNULL(@porcentajeIGV, 18.00);

        SELECT TOP 1
            @idPromocion = p.id,
            @porcentajeDescuento = CASE
                                       WHEN p.tipoDescuento = 'P' THEN p.valorDescuento
                                       WHEN p.tipoDescuento = 'M' THEN (p.valorDescuento / @monto * 100)
                                       ELSE 0
                END
        FROM Promocion p
                 LEFT JOIN PromocionProducto pp ON p.id = pp.idPromocion
        WHERE p.activo = 1
          AND CAST(GETDATE() AS DATE) BETWEEN p.fechaInicio AND p.fechaFin
          AND (p.aplicaATodos = 1 OR pp.idProducto = @idProducto)
          AND (@cantidad >= ISNULL(p.cantidadMinima, 0))
          AND (@monto >= ISNULL(p.montoMinimo, 0))
        ORDER BY
            CASE
                WHEN p.tipoDescuento = 'M' THEN p.valorDescuento
                WHEN p.tipoDescuento = 'P' THEN (@monto * p.valorDescuento / 100)
                ELSE 0
                END DESC;

        SET @porcentajeDescuento = ISNULL(@porcentajeDescuento, 0);

        INSERT INTO VentaDet (
            idVentaCab, idProducto, cantidad, precio,
            idPromocion, porcentajeDescuento, porcentajeIGV
        )
        VALUES (
                   @idVentaCab, @idProducto, @cantidad, @precio,
                   @idPromocion, @porcentajeDescuento, @porcentajeIGV
               );

        SET @idGenerado = SCOPE_IDENTITY();
        SET @resultado = 1;
        SET @mensaje = 'Detalle de venta creado exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
        SET @idGenerado = NULL;
    END CATCH
END
GO

CREATE PROCEDURE paVentaDetActualizar
    @id INT,
    @idVentaCab INT,
    @idProducto INT,
    @cantidad INT,
    @precio DECIMAL(10,2),
    @resultado INT OUTPUT,
    @mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @idPromocion INT = NULL;
        DECLARE @porcentajeDescuento DECIMAL(5,2) = 0;
        DECLARE @porcentajeIGV DECIMAL(5,2);
        DECLARE @monto DECIMAL(10,2) = @cantidad * @precio;

        IF NOT EXISTS (SELECT 1 FROM VentaDet WHERE id = @id AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='Detalle de venta no encontrado'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM VentaCab WHERE id = @idVentaCab AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='La venta cabecera no existe'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = @idProducto AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='El producto no existe'; ROLLBACK TRANSACTION; RETURN; END

        SELECT TOP 1 @porcentajeIGV = CAST(valor AS DECIMAL(5,2))
        FROM Parametro
        WHERE codigo = 'IGV'
          AND fechaVigencia <= CAST(GETDATE() AS DATE)
          AND (fechaFinVigencia IS NULL OR fechaFinVigencia >= CAST(GETDATE() AS DATE))
          AND activo = 1
        ORDER BY fechaVigencia DESC;
        SET @porcentajeIGV = ISNULL(@porcentajeIGV, 18.00);

        SELECT TOP 1
            @idPromocion = p.id,
            @porcentajeDescuento = CASE
                                       WHEN p.tipoDescuento = 'P' THEN p.valorDescuento
                                       WHEN p.tipoDescuento = 'M' THEN (p.valorDescuento / @monto * 100)
                                       ELSE 0
                END
        FROM Promocion p
                 LEFT JOIN PromocionProducto pp ON p.id = pp.idPromocion
        WHERE p.activo = 1
          AND CAST(GETDATE() AS DATE) BETWEEN p.fechaInicio AND p.fechaFin
          AND (p.aplicaATodos = 1 OR pp.idProducto = @idProducto)
          AND (@cantidad >= ISNULL(p.cantidadMinima, 0))
          AND (@monto >= ISNULL(p.montoMinimo, 0))
        ORDER BY
            CASE
                WHEN p.tipoDescuento = 'M' THEN p.valorDescuento
                WHEN p.tipoDescuento = 'P' THEN (@monto * p.valorDescuento / 100)
                ELSE 0
                END DESC;

        SET @porcentajeDescuento = ISNULL(@porcentajeDescuento, 0);

        UPDATE VentaDet SET
                            idVentaCab = @idVentaCab,
                            idProducto = @idProducto,
                            cantidad = @cantidad,
                            precio = @precio,
                            idPromocion = @idPromocion,
                            porcentajeDescuento = @porcentajeDescuento,
                            porcentajeIGV = @porcentajeIGV
        WHERE id = @id;

        SET @resultado = 1;
        SET @mensaje = 'Detalle de venta actualizado exitosamente';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- ========================================
-- PROCEDIMIENTOS SEPARADOS: Pago (Insert / Update)
-- ========================================
CREATE PROCEDURE paPagoInsertar
    @idVentaCab INT,
    @idTipoPago INT,
    @monto DECIMAL(10,2),
    @observacion VARCHAR(100) = NULL,
    @fecha DATE,
    @resultado INT OUTPUT,
    @mensaje VARCHAR(200) OUTPUT,
    @idGenerado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @idVentaCab IS NULL OR @idVentaCab <= 0
            BEGIN SET @resultado=0; SET @mensaje='Venta inválida'; ROLLBACK TRANSACTION; RETURN; END
        IF @idTipoPago IS NULL OR @idTipoPago <= 0
            BEGIN SET @resultado=0; SET @mensaje='Tipo de pago inválido'; ROLLBACK TRANSACTION; RETURN; END
        IF @monto IS NULL OR @monto <= 0
            BEGIN SET @resultado=0; SET @mensaje='Monto debe ser mayor a 0'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM VentaCab WHERE id = @idVentaCab AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='La venta especificada no existe'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM TipoPago WHERE id = @idTipoPago AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='El tipo de pago especificado no existe'; ROLLBACK TRANSACTION; RETURN; END

        DECLARE @totalVenta DECIMAL(10,2);
        DECLARE @totalPagado DECIMAL(10,2);

        SELECT @totalVenta = c.total
        FROM VentaCab v INNER JOIN Comprobante c ON v.idComprobante = c.id
        WHERE v.id = @idVentaCab;

        SELECT @totalPagado = ISNULL(SUM(monto), 0)
        FROM Pago
        WHERE idVentaCab = @idVentaCab AND activo = 1;

        IF (@totalPagado + @monto) > @totalVenta
            BEGIN SET @resultado=0; SET @mensaje='El monto del pago excede el saldo pendiente. Total venta: ' + CAST(@totalVenta AS VARCHAR) + ', Ya pagado: ' + CAST(@totalPagado AS VARCHAR); ROLLBACK TRANSACTION; RETURN; END

        INSERT INTO Pago (
            idVentaCab, idTipoPago, monto, observacion, fecha
        )
        VALUES (
                   @idVentaCab, @idTipoPago, @monto, @observacion, @fecha
               );

        SET @idGenerado = SCOPE_IDENTITY();
        SET @resultado = 1;
        SET @mensaje = 'Pago registrado exitosamente';

        IF (@totalPagado + @monto) = @totalVenta
            BEGIN
                UPDATE VentaCab SET estado = 'COMPLETADO' WHERE id = @idVentaCab;
            END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
        SET @idGenerado = NULL;
    END CATCH
END
GO

CREATE PROCEDURE paPagoActualizar
    @id INT,
    @idVentaCab INT,
    @idTipoPago INT,
    @monto DECIMAL(10,2),
    @observacion VARCHAR(100) = NULL,
    @fecha DATE,
    @resultado INT OUTPUT,
    @mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM Pago WHERE id = @id AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='Pago no encontrado'; ROLLBACK TRANSACTION; RETURN; END
        IF @idVentaCab IS NULL OR @idVentaCab <= 0
            BEGIN SET @resultado=0; SET @mensaje='Venta inválida'; ROLLBACK TRANSACTION; RETURN; END
        IF @idTipoPago IS NULL OR @idTipoPago <= 0
            BEGIN SET @resultado=0; SET @mensaje='Tipo de pago inválido'; ROLLBACK TRANSACTION; RETURN; END
        IF @monto IS NULL OR @monto <= 0
            BEGIN SET @resultado=0; SET @mensaje='Monto debe ser mayor a 0'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM VentaCab WHERE id = @idVentaCab AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='La venta especificada no existe'; ROLLBACK TRANSACTION; RETURN; END
        IF NOT EXISTS (SELECT 1 FROM TipoPago WHERE id = @idTipoPago AND activo = 1)
            BEGIN SET @resultado=0; SET @mensaje='El tipo de pago especificado no existe'; ROLLBACK TRANSACTION; RETURN; END

        DECLARE @totalVenta DECIMAL(10,2);
        DECLARE @totalPagado DECIMAL(10,2);

        SELECT @totalVenta = c.total
        FROM VentaCab v INNER JOIN Comprobante c ON v.idComprobante = c.id
        WHERE v.id = @idVentaCab;

        SELECT @totalPagado = ISNULL(SUM(monto), 0)
        FROM Pago
        WHERE idVentaCab = @idVentaCab AND activo = 1 AND id != @id;

        IF (@totalPagado + @monto) > @totalVenta
            BEGIN SET @resultado=0; SET @mensaje='El monto del pago excede el saldo pendiente. Total venta: ' + CAST(@totalVenta AS VARCHAR) + ', Ya pagado: ' + CAST(@totalPagado AS VARCHAR); ROLLBACK TRANSACTION; RETURN; END

        UPDATE Pago SET
                        idVentaCab = @idVentaCab,
                        idTipoPago = @idTipoPago,
                        monto = @monto,
                        observacion = @observacion,
                        fecha = @fecha
        WHERE id = @id;

        SET @resultado = 1;
        SET @mensaje = 'Pago actualizado exitosamente';

        IF (@totalPagado + @monto) = @totalVenta
            BEGIN
                UPDATE VentaCab SET estado = 'COMPLETADO' WHERE id = @idVentaCab;
            END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @resultado = 0;
        SET @mensaje = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO
---







-- TABLA VENTADET: Agregar campos para IGV y Promociones
ALTER TABLE VentaDet ADD idPromocion INT NULL;
ALTER TABLE VentaDet ADD porcentajeDescuento DECIMAL(5,2) NOT NULL DEFAULT 0;
ALTER TABLE VentaDet ADD montoDescuento AS (cantidad * precio * porcentajeDescuento / 100) PERSISTED;
ALTER TABLE VentaDet ADD porcentajeIGV DECIMAL(5,2) NOT NULL DEFAULT 18.00;
ALTER TABLE VentaDet ADD montoIGV AS (cantidad * precio * (1 - porcentajeDescuento / 100) * porcentajeIGV / 100) PERSISTED;
ALTER TABLE VentaDet ADD subtotalSinDescuento AS (cantidad * precio) PERSISTED;
ALTER TABLE VentaDet ADD subtotalConDescuento AS (cantidad * precio * (1 - porcentajeDescuento / 100)) PERSISTED;
ALTER TABLE VentaDet ADD totalConIGV AS (cantidad * precio * (1 - porcentajeDescuento / 100) * (1 + porcentajeIGV / 100)) PERSISTED;

-- Agregar FK para promoción
ALTER TABLE VentaDet ADD CONSTRAINT FK_VentaDet_Promocion
    FOREIGN KEY (idPromocion) REFERENCES Promocion(id);

-- Agregar constraints de validación
ALTER TABLE VentaDet ADD CONSTRAINT CHK_VentaDet_PorcentajeDescuento
    CHECK (porcentajeDescuento BETWEEN 0 AND 100);
ALTER TABLE VentaDet ADD CONSTRAINT CHK_VentaDet_PorcentajeIGV
    CHECK (porcentajeIGV >= 0);

-- TABLA PEDIDODET: Agregar campos para IGV y Promociones
ALTER TABLE PedidoDet ADD idPromocion INT NULL;
ALTER TABLE PedidoDet ADD porcentajeDescuento DECIMAL(5,2) NOT NULL DEFAULT 0;
ALTER TABLE PedidoDet ADD montoDescuento AS (cantidad * precio * porcentajeDescuento / 100) PERSISTED;
ALTER TABLE PedidoDet ADD porcentajeIGV DECIMAL(5,2) NOT NULL DEFAULT 18.00;
ALTER TABLE PedidoDet ADD montoIGV AS (cantidad * precio * (1 - porcentajeDescuento / 100) * porcentajeIGV / 100) PERSISTED;
ALTER TABLE PedidoDet ADD subtotalSinDescuento AS (cantidad * precio) PERSISTED;
ALTER TABLE PedidoDet ADD subtotalConDescuento AS (cantidad * precio * (1 - porcentajeDescuento / 100)) PERSISTED;
ALTER TABLE PedidoDet ADD totalConIGV AS (cantidad * precio * (1 - porcentajeDescuento / 100) * (1 + porcentajeIGV / 100)) PERSISTED;

-- Agregar FK para promoción
ALTER TABLE PedidoDet ADD CONSTRAINT FK_PedidoDet_Promocion
    FOREIGN KEY (idPromocion) REFERENCES Promocion(id);

-- Agregar constraints de validación
ALTER TABLE PedidoDet ADD CONSTRAINT CHK_PedidoDet_PorcentajeDescuento
    CHECK (porcentajeDescuento BETWEEN 0 AND 100);
ALTER TABLE PedidoDet ADD CONSTRAINT CHK_PedidoDet_PorcentajeIGV
    CHECK (porcentajeIGV >= 0);

-- TABLA COMPROBANTE: Agregar porcentajeIGV
ALTER TABLE Comprobante ADD porcentajeIGV DECIMAL(5,2) NOT NULL;

-- Actualizar constraint de total correcto (con tolerancia por redondeo)
ALTER TABLE Comprobante DROP CONSTRAINT IF EXISTS CHK_Comprobante_TotalCorrecto;
ALTER TABLE Comprobante ADD CONSTRAINT CHK_Comprobante_TotalCorrecto
    CHECK (ABS(total - (subtotal + igv)) < 0.01);
