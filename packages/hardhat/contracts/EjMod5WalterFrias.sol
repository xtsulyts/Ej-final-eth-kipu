// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/*
Interface: IGrader
    Descripción: Define un conjunto de funciones que otros contratos deben implementar 
    para interactuar con funcionalidades específicas, como realizar pagos, acuñar tokens 
    y registrar datos con nombres.

    Métodos:
        - retrieve2(): Función pagadera para manejar pagos desde contratos externos.
        - mint(address to): Permite acuñar un token y asignarlo a una dirección específica.
        - gradeMe(string calldata name): Procesa datos enviados como un nombre y realiza 
          operaciones relacionadas.

        Función: retrieve2
        Descripción: Permite a contratos externos enviar Ether al contrato. 
        Esta función es pagadera, lo que significa que puede recibir fondos.
        Modificador: external - Puede ser llamada únicamente desde fuera del contrato.

        Función: mint
        Descripción: Acuña un token y lo asigna a la dirección especificada.
        Parámetros:
            - to: Dirección de la cuenta que recibirá el token acuñado.
        Modificador: external - Puede ser llamada únicamente desde fuera del contrat

        Función: gradeMe
        Descripción: Realiza una operación utilizando un nombre proporcionado como entrada.
        Parámetros:
            - name: Una cadena de texto pasada como argumento, que contiene un nombre.
        Modificador: external - Puede ser llamada únicamente desde fuera del contrato.
    */

interface IGrader {
    function retrieve2() external payable;
    function mint(address to) external;
    function gradeMe(string calldata name) external;
}


/*
Contrato: ProxyGrader
    Descripción: Este contrato actúa como un proxy para interactuar con otro contrato, 
    cuyo direccionamiento se define al desplegar el contrato. Proporciona un mecanismo 
    para delegar llamadas a un contrato específico mediante la variable `graderContract`.

    Variables:
        - graderContract: Almacena la dirección del contrato objetivo con el que 
          el proxy interactuará.
*/
contract ProxyGrader {
    address public graderContract;

    /*
    Constructor:
        - Configura la dirección inicial del contrato objetivo al desplegar el contrato.
        Variable: graderContract
        Descripción: Dirección pública del contrato objetivo con el que se delegarán las llamadas.
        Visibilidad: public - Permite acceder a su valor desde fuera del contrato.
    */
    constructor(address _graderContract) {
        graderContract = _graderContract; 
    }

    /*
    Función: callRetrieve2
        Descripción: Llama a la función `retrieve2` del contrato objetivo (`graderContract`) 
        y transfiere Ether junto con la llamada. Garantiza que el monto enviado sea mayor 
        que 3 wei antes de realizar la interacción.

        Detalles:
            - Usa el patrón Checks-Effects-Interactions para validar el monto antes 
              de interactuar con el contrato externo.
            - Delegación de la llamada se realiza al contrato `IGrader`.

        Parámetros:
            - No tiene parámetros directos. Utiliza `msg.value` para manejar el Ether enviado.

        Restricciones:
            - El monto de Ether enviado (`msg.value`) debe ser mayor a 3 wei. De lo contrario, 
              se revierte la transacción con un mensaje de error.
        
        Modificador:
            - external: Solo puede ser llamada desde fuera del contrato.
            - payable: Permite que la función reciba Ether durante la llamada.
    */
    function callRetrieve2() external payable {
        require(msg.value > 3, "Send more than 3 wei");
        IGrader(graderContract).retrieve2{value: msg.value}();
    }

    /*
    Función: callGradeMe
        Descripción: Llama a la función `gradeMe` del contrato objetivo (`graderContract`) 
        pasando un nombre como argumento. Permite delegar esta operación al contrato externo.

        Parámetros:
            - name: Una cadena de texto (`string`) proporcionada como argumento, que se 
              utiliza en la función `gradeMe` del contrato objetivo.

        Detalles:
            - La llamada se delega al contrato `IGrader` definido en `graderContract`.
        
        Modificador:
            - external: Solo puede ser llamada desde fuera del contrato.
        interacción: Llama a la función `gradeMe` del contrato graderContract, 
        pasando el argumento `name`.
    */
        function callGradeMe(string calldata name) external {
            IGrader(graderContract).gradeMe(name);
        }

     /*
    Función: withdraw
        Descripción: Permite al remitente recuperar el saldo almacenado en el contrato. 
        Esta función transfiere el saldo disponible de vuelta a la dirección del remitente.

        Detalles:
            - Usa la propiedad `msg.sender` para identificar al remitente de la transacción.
            - Transfiere Ether al remitente utilizando `payable(msg.sender)`.
            - No tiene parámetros ni requiere Ether para ejecutarse.

        Modificador:
            - external: Solo puede ser llamada desde fuera del contrato.
    */   
    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    /*
    Función: receive
        Descripción: Función especial en Solidity que permite al contrato recibir Ether 
        directamente sin necesidad de llamar a una función específica. Es ejecutada 
        automáticamente cuando el contrato recibe Ether sin datos asociados.

        Detalles:
            - Es pagadera (`payable`), lo que permite aceptar transferencias de Ether.
            - No tiene parámetros ni cuerpo de ejecución adicional.
            - Actúa como un fallback simplificado para recibir Ether.

        Modificador:
            - external: Solo puede ser llamada desde fuera del contrato.
            - payable: Permite que el contrato reciba fondos en forma de Ether.
    */
    receive() external payable {}
}

