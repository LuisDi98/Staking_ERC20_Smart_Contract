# Staking_ERC20_Smart_Contract

## Descripción
El contrato permite hacer staking flexible de tokens.

El usuario puede:
- Decidir la cantidad de tokens a **bloquear (stake)** dentro del contrato
- Decidir la cantidad de tokens a **desbloquear (unstake)**

La cantidad de tokens de recompensa se determinar segun el APR (Annual Percentage Rate) definido por el owner del contrato. 

## Razonamiento

- Se uso una estructura **Staker** para una mejor gestión de los tokens en staking y el registro de los tiempos de staking y unstaking.
- Se utilizaron **basis points (bps)** para tener una representacion más precisas de porcentajes.

## Patrones de diseño

- Reentrancy Guard: Debido a que los metodos unstake y claimReward permiten sacar fondos de la billetera y de los balances del contrato, queremos evitar que un atacante pueda llamar repetidamente estas funciones y desviar fondos.


## Integrantes
- Christian D. Calderón Tenorio
- Pablo Guerrero Calvo
- Luis Diego Mora Aguilar
