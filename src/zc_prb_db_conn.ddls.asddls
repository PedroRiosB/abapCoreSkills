@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_PRB_DB_CONN
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_PRB_DB_CONN
{
  key Uuid,
  Carrid,
  Connid,
  AirportFrom,
  CityFrom,
  CountryFrom,
  AirportTo,
  CityTo,
  CountryTo,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
