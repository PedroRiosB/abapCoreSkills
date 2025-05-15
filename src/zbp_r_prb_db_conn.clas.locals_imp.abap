CLASS LHC_ZR_PRB_DB_CONN DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrPrbDbConn
        RESULT result,
      zcheckSemanticKey FOR VALIDATE ON SAVE
            IMPORTING keys FOR ZrPrbDbConn~zcheckSemanticKey,
      zgetCities FOR DETERMINE ON SAVE
            IMPORTING keys FOR ZrPrbDbConn~zgetCities.
ENDCLASS.

CLASS LHC_ZR_PRB_DB_CONN IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
  METHOD zcheckSemanticKey.
    READ entities of zr_prb_db_conn in LOCAL MODE
    ENTITY ZrPrbDbConn FIELDS ( uuid carrid Connid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_conn).

    LOOP AT lt_conn INTO DATA(ls_conn).
        SELECT SINGLE from zprb_db_conn
        FIELDS uuid
        WHERE carrid = @ls_conn-Carrid
          AND connid = @ls_conn-Connid
        into @data(lv_uuid).

        if lv_uuid is NOT INITIAL.
            DATA(ls_msg) = me->new_message(
                id = 'ZS4D400_PRB_MC'
                number = 2
                severity = ms-error
                v1 = ls_conn-Carrid
                v2 = ls_conn-Connid
             ).

            DATA ls_rep_rec like LINE OF reported-zrprbdbconn.
            ls_rep_rec-%tky = ls_conn-%tky.
            ls_rep_rec-%msg = ls_msg.
            ls_rep_rec-%element-carrid = if_abap_behv=>mk-on.
            ls_rep_rec-%element-connid = if_abap_behv=>mk-on.
            append ls_rep_rec to reported-zrprbdbconn.

            DATA ls_fail_rec like LINE OF failed-zrprbdbconn.
            ls_fail_rec-%tky = ls_conn-%tky.
            append ls_fail_rec to failed-zrprbdbconn.
        endif.
    ENDLOOP.

  ENDMETHOD.

  METHOD zgetCities.
   READ ENTITIES OF zr_prb_db_conn IN LOCAL MODE
    ENTITY ZrPrbDbConn FIELDS ( CityFrom CityTo )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_conn).

    LOOP AT lt_conn INTO DATA(ls_conn).
        SELECT SINGLE from /dmo/i_airport
        FIELDS City, CountryCode
        WHERE AirportID = @ls_conn-AirportFrom
        INTO (@ls_conn-CityFrom, @ls_conn-AirportFrom ).

        SELECT SINGLE from /dmo/i_airport
        FIELDS City, CountryCode
        WHERE AirportID = @ls_conn-AirportTo
        INTO (@ls_conn-CityTo, @ls_conn-AirportTo).

        MODIFY lt_conn FROM ls_conn.
    ENDLOOP.

    DATA lt_upd_data TYPE TABLE FOR UPDATE zr_prb_db_conn.
    lt_upd_data = CORRESPONDING #( lt_conn ).

    MODIFY ENTITies of zr_prb_db_conn in LOCAL MODE
     ENTITY ZrPrbDbConn
     UPDATE
     fields ( CityFrom CountryFrom CityTo CountryTo )
     WITH lt_upd_data
     REPORTED DATA(lt_rep_records).

   reported-zrprbdbconn = CORRESPONDING #( lt_rep_records-zrprbdbconn ).

  ENDMETHOD.

ENDCLASS.
