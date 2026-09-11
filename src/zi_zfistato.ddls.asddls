@EndUserText.label: 'ZFI_STATO'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_ZfiStato
  as select from ZFI_STATO
  association to parent ZI_ZfiStato_S as _ZfiStatoAll on $projection.SingletonID = _ZfiStatoAll.SingletonID
{
  key CODE as Code,
  DESCRIPTION as Description,
  @Consumption.hidden: true
  1 as SingletonID,
  _ZfiStatoAll
}
