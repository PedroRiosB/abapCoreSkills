*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class lcl_connection definition .

  public section.

  CLASS-DATA conn_counter TYPE i READ-ONLY.
  METHODS set_attributes IMPORTING i_carrier_id type /dmo/carrier_id OPTIONAL
                                   i_connection_id TYPE /dmo/connection_id
                         RAISING
                           cx_abap_invalid_value.
  METHODS get_attrinutes IMPORTING i_carrier_id type /dmo/carrier_id OPTIONAL
                                   i_connection_id TYPE /dmo/connection_id.

   METHODS get_output RETURNING VALUE(r_output) TYPE string_table.

   CLASS-METHODS test importing i_test type /dmo/carrier_id.

  protected section.
  private section.
    DATA carrier_id TYPE /dmo/carrier_id.
    DATA connection_id type /dmo/connection_id.

endclass.

class lcl_connection implementation.

  method set_attributes.
    if i_carrier_id is initial or i_connection_id is initial.
      RAISE EXCEPTION type cx_abap_invalid_value.
    endif.
    carrier_id = i_carrier_id.
    connection_id = i_connection_id.
    conn_counter = conn_counter + 1.
  endmethod.

  method get_attrinutes.

  endmethod.

  method get_output.
    APPEND |------------------------------| TO r_output.
    APPEND |Carrier:     { carrier_id    }| TO r_output.
    APPEND |Connection:  { connection_id }| TO r_output.
  endmethod.

  method test.

  endmethod.

endclass.
