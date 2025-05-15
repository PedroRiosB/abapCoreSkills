CLASS zcl_prb_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_prb_eml IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    data update_tab type TABLE FOR update /DMO/R_AgencyTP.
    update_tab = VALUE #( ( AgencyID = '070014' Name = 'MODIFIED Kangeroos' ) ).
    MODIFY ENTITIES OF /DMO/R_AgencyTP
    ENTITY /DMO/Agency
    update FIELDS ( name )
    WITH update_tab.

    commit ENTITIES.

    out->write( `Method execution finished!`  ).

  ENDMETHOD.

ENDCLASS.
