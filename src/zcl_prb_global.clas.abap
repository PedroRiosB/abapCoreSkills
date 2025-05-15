CLASS zcl_prb_global DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    METHODS:
      local_class IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      complex_types IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      abap_sql IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      fill_zconn_table IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      unused_variables IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      conversion_types IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_prb_global IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*    me->local_class( out ).
*    me->complex_types( out ).
*     me->abap_sql( out ).
*     me->fill_zconn_table( out ).
*    me->unused_variables( out ).
    me->conversion_types( out ).
  ENDMETHOD.
  METHOD local_class.

    DATA connection TYPE REF TO lcl_connection.
    DATA connections TYPE TABLE OF REF TO lcl_connection.

    connection = NEW #(  ).
    TRY.
        connection->set_attributes( i_carrier_id = 'LH' i_connection_id = '0400' ).
        APPEND connection TO connections.
        out->write( `Method call successful` ).
      CATCH cx_abap_invalid_value.
        out->write( `Method call failed`     ).
    ENDTRY.


    connection = NEW #( ).
    TRY.
        connection->set_attributes(
          EXPORTING
            i_carrier_id    = 'AA'
            i_connection_id = '0017'
        ).

        APPEND connection TO connections.

      CATCH cx_abap_invalid_value.
        out->write( `Method call failed` ).
    ENDTRY.

* Third instance
**********************************************************************
    connection = NEW #(  ).

    TRY.
        connection->set_attributes(
          EXPORTING
            i_carrier_id    = 'SQ'
            i_connection_id = '0001'
        ).

        APPEND connection TO connections.

      CATCH cx_abap_invalid_value.
        out->write( `Method call failed` ).
    ENDTRY.

* Output
**********************************************************************

    LOOP AT connections INTO connection.

      out->write( connection->get_output( ) ).

    ENDLOOP.

    DATA airport_from_id TYPE /DMO/airport_from_id.
    DATA airport_to_id   TYPE /DMO/airport_to_id.


    DATA airports TYPE TABLE OF /DMO/airport_from_id.

* Example 1: Single field from Single Record
**********************************************************************
    SELECT SINGLE
      FROM /dmo/connection
      FIELDS airport_from_id
      WHERE carrier_id    = 'LH'
        AND connection_id = '0400'
        INTO @airport_from_id.

    out->write( `----------`  ).
    out->write( `Example 1:`  ).

    out->write( |Flight LH 400 departs from {  airport_from_id }.| ).

* Example 2: Multiple Fields from Single Record
**********************************************************************
    SELECT SINGLE
      FROM /dmo/connection
      FIELDS airport_from_id, airport_to_id
      WHERE carrier_id    = 'LH'
        AND connection_id = '0400'
        INTO (  @airport_from_id, @airport_to_id ).

    out->write( `----------`  ).
    out->write( `Example 2:`  ).

    out->write( |Flight LH 400 flies from {  airport_from_id } to { airport_to_id  }| ).

* Example 3: Empty Result and sy-subrc
**********************************************************************
    SELECT SINGLE
      FROM /dmo/connection
      FIELDS airport_from_id
      WHERE carrier_id    = 'XX'
        AND connection_id = '1234'
        INTO @airport_from_id.

    IF sy-subrc = 0.

      out->write( `----------`  ).
      out->write( `Example 3:`  ).
      out->write( |Flight XX 1234 departs from {  airport_from_id }.| ).

    ELSE.

      out->write( `----------`  ).
      out->write( `Example 3:`  ).
      out->write( |There is no flight XX 1234, but still airport_from_id = {  airport_from_id }!| ).

    ENDIF.

    SELECT
     FROM /dmo/connection
     FIELDS airport_from_id,
            airport_to_id,
            distance,
            distance_unit
     WHERE carrier_id    = 'LH'
*        AND connection_id = '0400'
       INTO TABLE @DATA(lt_conn).
    IF sy-subrc EQ 0.
      LOOP AT lt_conn INTO DATA(ls_conn).
*            out->write( |Flights from LH to { ls_conn-airport_to_id } -> { ls_conn-distance } { ls_conn-distance_unit } | ).
        out->write( ls_conn  ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD complex_types.


    TYPES: BEGIN OF st_connection,
             carrier_id      TYPE /dmo/carrier_id,
             connection_id   TYPE /dmo/connection_id,
             airport_from_id TYPE /dmo/airport_from_id,
             airport_to_id   TYPE /dmo/airport_to_id,
             carrier_name    TYPE /dmo/carrier_name,
           END OF st_connection.

    TYPES tt_connections TYPE STANDARD TABLE OF   st_connection
                              WITH NON-UNIQUE KEY carrier_id
                                                  connection_id.

    DATA connections TYPE tt_connections.

    TYPES: BEGIN OF st_carrier,
             carrier_id    TYPE /dmo/carrier_id,
             carrier_name  TYPE /dmo/carrier_name,
             currency_code TYPE /dmo/currency_code,
           END OF st_carrier.

    TYPES tt_carriers TYPE STANDARD TABLE OF st_carrier
                          WITH NON-UNIQUE KEY carrier_id.

    DATA carriers TYPE tt_carriers.
    DATA lt_carriers TYPE SORTED TABLE OF st_carrier
                           WITH NON-UNIQUE KEY carrier_id.

* Example 1: APPEND with structured data object (work area)
**********************************************************************

*    DATA connection  TYPE st_connection.
    " Declare the work area with LIKE LINE OF
    DATA connection LIKE LINE OF connections.


*    connection-carrier_id       = 'NN'.
*    connection-connection_id    = '1234'.
*    connection-airport_from_id  = 'ABC'.
*    connection-airport_to_id    = 'XYZ'.
*    connection-carrier_name     = 'My Airline'.

    " Use VALUE #( ) instead assignment to individual components
    connection = VALUE #( carrier_id       = 'NN'
                          connection_id    = '1234'
                          airport_from_id  = 'ABC'
                          airport_to_id    = 'XYZ'
                          carrier_name     = 'My Airline' ).

    APPEND connection TO connections.

    out->write(  `--------------------------------` ).
    out->write(  `Example 1: APPEND with Work Area` ).
    out->write(  connections ).

* Example 2: APPEND with VALUE #( ) expression
**********************************************************************

    APPEND VALUE #( carrier_id       = 'NN'
                    connection_id    = '1234'
                    airport_from_id  = 'ABC'
                    airport_to_id    = 'XYZ'
                    carrier_name     = 'My Airline'
                  )
       TO connections.

    out->write(  `----------------------------` ).
    out->write(  `Example 2: Append with VALUE` ).
    out->write(  connections ).

* Example 3: Filling an Internal Table with Several Rows
**********************************************************************

    carriers = VALUE #(  (  carrier_id = 'AA' carrier_name = 'American Airlines' )
                         (  carrier_id = 'JL' carrier_name = 'Japan Airlines'    )
                         (  carrier_id = 'SQ' carrier_name = 'Singapore Airlines' )
                      ).

    out->write(  `-----------------------------------------` ).
    out->write(  `Example 3: Fill Internal Table with VALUE` ).
    out->write(  carriers ).


* Example 4: Filling one Internal Table from Another
**********************************************************************

    connections = CORRESPONDING #( carriers ).

    out->write(  `--------------------------------------------` ).
    out->write(  `Example 4: CORRESPONDING for Internal Tables` ).
    out->write(  data = carriers
                 name = `Source Table CARRIERS:` ).
    out->write(  data = connections
                 name = `Target Table CONNECTIONS:` ).

* Example 5: Filling one Internal sorted table
**********************************************************************
    lt_carriers = VALUE #(  (  carrier_id = 'AA' carrier_name = 'American Airlines' )
                            (  carrier_id = 'AA' carrier_name = 'American Airlines 2'    )
                            (  carrier_id = 'SQ' carrier_name = 'Singapore Airlines' )
                          ).

    out->write(  `--------------------------------------------` ).
    out->write(  `Example 5: sorted table no unique key` ).
    out->write(  data = lt_carriers
                 name = `CARRIERS sorted:` ).

*   Read TABLE

    DATA(carrier) = lt_carriers[ carrier_id = 'SQ' carrier_name = 'Singapore Airlines' ] .
    DATA result TYPE string.

    result = 'Subrc:' && sy-subrc.
    out->write(  `--------------------------------------------` ).
    out->write(  `Read Table` ).
    out->write(  data = carrier
                 name = result ).


  ENDMETHOD.

  METHOD abap_sql.
    TYPES: BEGIN OF st_airport,
             airportid TYPE /dmo/airport_id,
             name      TYPE /dmo/airport_name,
           END OF st_airport.

    TYPES tt_airports TYPE STANDARD TABLE OF st_airport
                          WITH NON-UNIQUE KEY airportid.

    DATA airports TYPE tt_airports.


* Example 1: Structured Variables in SELECT SINGLE ... INTO ...
**********************************************************************

    DATA airport_full TYPE /DMO/I_Airport.

    SELECT SINGLE
      FROM /DMO/I_Airport
    FIELDS AirportID, Name, City, CountryCode
     WHERE City = 'Zurich'
      INTO @airport_full.

    out->write(  `-------------------------------------` ).
    out->write(  `Example 1: SELECT SINGLE ... INTO ...` ).
    out->write(  data = airport_full
                 name = `One of the airports in Zurich (Structure):` ).

* Example 2: Internal Tables in SELECT ... INTO TABLE ...
**********************************************************************

    DATA airports_full TYPE STANDARD TABLE OF /DMO/I_Airport
                            WITH NON-UNIQUE KEY AirportID.

    SELECT
      FROM /DMO/I_Airport
    FIELDS airportid, Name, City, CountryCode
     WHERE City = 'London'
      INTO TABLE @airports_full.

    out->write(  `------------------------------------` ).
    out->write(  `Example 2: SELECT ... INTO TABLE ...` ).
    out->write(  data = airports_full
                 name = `All airports in London (Internal Table):` ).

* Example 3: FIELDS * and INTO CORRESPONDING FIELDS OF TABLE
**********************************************************************

    SELECT
      FROM /DMO/I_Airport
    FIELDS *
     WHERE City = 'London'
      INTO CORRESPONDING FIELDS OF TABLE @airports.

    out->write(  `----------------------------------------------------------` ).
    out->write(  `Example 3: FIELDS * and INTO CORRESPONDING FIELDS OF TABLE` ).
    out->write(  data = airports
                 name = `Internal Table AIRPORTS:` ).

* Example 4: Inline Declaration
**********************************************************************

    SELECT
      FROM /DMO/I_airport
    FIELDS AirportID, Name AS AirportName
     WHERE City = 'London'
     INTO TABLE @DATA(airports_inline).

    out->write(  `----------------------------------------------------------` ).
    out->write(  `Example 4: Inline Declaration after INTO TABLE` ).
    out->write(  data = airports_inline
                 name = `Internal Table AIRPORTS_INLINE:` ).

** Example 4: ORDER BY and DISTINCT
***********************************************************************
*
*    SELECT
*      FROM /DMO/I_Airport
*    FIELDS DISTINCT CountryCode
*     ORDER BY CountryCode
*     INTO TABLE @DATA(countryCodes).
*
*    out->write(  countryCodes ).

* Example 5: UNION (ALL)
**********************************************************************

    SELECT FROM /DMO/I_Carrier
           FIELDS 'Airline' AS type, AirlineID AS Id, Name
           WHERE CurrencyCode = 'GBP'

    UNION ALL

    SELECT FROM /DMO/I_Airport
           FIELDS 'Airport' AS type, AirportID AS Id,  Name
           WHERE City = 'London'
*    ORDER BY type, Id
    INTO TABLE @DATA(names).

    out->write(  `----------------------------------------------` ).
    out->write(  `Example 5: UNION ALL of Airlines and Airports ` ).
    out->write(  data = names
                 name = `ID and Name of Airlines and Airports:` ).
  ENDMETHOD.

  METHOD fill_zconn_table.
    DATA: lt_conn TYPE TABLE OF zprb_db_conn.

    out->write( 'start: ' ).

    SELECT FROM /DMO/I_Connection AS c
          LEFT OUTER JOIN /DMO/Airport AS f ON c~DepartureAirport = f~airport_id
          LEFT OUTER JOIN /dmo/airport AS t ON c~DestinationAirport = t~airport_id
          FIELDS c~AirlineID AS carrid, c~ConnectionID AS connid, c~DepartureAirport AS airport_from, t~city AS city_from, c~DestinationAirport AS airport_to, t~city AS city_to, t~country AS country_to
          INTO TABLE @DATA(result_tab).

    out->write( 'Lines retrieved: ' ).
    DATA(lv_lines) = lines( result_tab ).
    out->write( lv_lines ).

    DELETE FROM zprb_db_conn.

    LOOP AT result_tab INTO DATA(line).
      DATA ls_conn TYPE zprb_db_conn.
      CLEAR ls_conn.
      " Automatically map fields using MOVE-CORRESPONDING
      ls_conn = CORRESPONDING #( line ).
      TRY.
          ls_conn-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      " Set the client field
      ls_conn-client = sy-mandt.  " Correct client

      " Add audit fields manually
*      table_row-local_created_by = cl_abap_context_info=>get_user_technical_name(  ).
*      table_row-local_created_at = cl_abap_context_info=>get_system_time(  ).
*      table_row-local_last_changed_by = cl_abap_context_info=>get_user_technical_name(  ).
*      table_row-local_last_changed_at = cl_abap_context_info=>get_system_time(  ).
*      table_row-last_changed_at = cl_abap_context_info=>get_system_time(  ).

      APPEND ls_conn TO lt_conn.

    ENDLOOP.

    IF lt_conn IS NOT INITIAL.
      INSERT zprb_db_conn FROM TABLE @lt_conn.
    ENDIF.

    out->write( 'Finished ' ).
  ENDMETHOD.

  METHOD unused_variables.
    DATA lv_connid TYPE /dmo/agency.

    SELECT FROM /dmo/connection
    FIELDS *
    INTO TABLE @DATA(lt_conn).
    LOOP AT lt_conn INTO DATA(ls_conn).
      SELECT SINGLE FROM /dmo/airport
          FIELDS *
          WHERE airport_id = @ls_conn-airport_from_id
          INTO @DATA(ls_airp).
    ENDLOOP.

    out->write( lt_conn ).
  ENDMETHOD.

  METHOD conversion_types.
    DATA var_date   TYPE d.
    DATA var_pack   TYPE p LENGTH 3 DECIMALS 2.
    DATA var_string TYPE string.
    DATA var_char   TYPE c LENGTH 3.

    var_pack = 1 / 8.
    out->write( |1/8 = { var_pack NUMBER = USER }| ).

    TRY.
        var_pack = EXACT #( 1 / 8 ).
      CATCH cx_sy_conversion_error.
        out->write( |1/8 has to be rounded. EXACT triggered an exception| ).
    ENDTRY.

    var_string = 'ABCDE'.
    var_char   = var_string.
    out->write( var_char ).

    TRY.
        var_char = EXACT #( var_string ).
      CATCH cx_sy_conversion_error.
        out->write( 'String has to be truncated. EXACT triggered an exception' ).
    ENDTRY.

    var_date = 'ABCDEFGH'.
    out->write( var_Date ).

    TRY.
        var_date = EXACT #( 'ABCDEFGH' ).
      CATCH cx_sy_conversion_error.
        out->write( |ABCDEFGH is not a valid date. EXACT triggered an exception| ).
    ENDTRY.


    var_date = '20221232'.
    out->write( var_date ).


    TRY.
        var_date = EXACT #( '20221232' ).
      CATCH cx_sy_conversion_error.
        out->write( |2022-12-32 is not a valid date. EXACT triggered an exception| ).
    ENDTRY.


    DATA timestamp1 TYPE utclong.
    DATA timestamp2 TYPE utclong.
    DATA difference TYPE decfloat34.
    DATA date_user TYPE d.
    DATA time_user TYPE t.

    timestamp1 = utclong_current( ).
    out->write( |Current UTC time { timestamp1 }| ).

    timestamp2 = utclong_add( val = timestamp1 days = 7 ).
    out->write( |Added 7 days to current UTC time { timestamp2 }| ).

    difference = utclong_diff( high = timestamp2 low = timestamp1 ).
    out->write( |Difference between timestamps in seconds: { difference }| ).

    out->write( |Difference between timestamps in days: { difference / 3600 / 24 }| ).

    CONVERT UTCLONG utclong_current( )
       INTO DATE date_user
            TIME time_user
            TIME ZONE cl_abap_context_info=>get_user_time_zone( ).

    out->write( |UTC timestamp split into date (type D) and time (type T )| ).
    out->write( |according to the user's time zone (cl_abap_context_info=>get_user_time_zone( ) ).| ).
    out->write( |{ date_user DATE = USER }, { time_user TIME = USER }| ).
  ENDMETHOD.

ENDCLASS.
