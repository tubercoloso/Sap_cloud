@EndUserText.label: 'ZFI_TP_DOC'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_ZfiTpDoc
  as select from ZFI_TP_DOC
  association to parent ZI_ZfiTpDoc_S as _ZfiTpDocAll on $projection.SingletonID = _ZfiTpDocAll.SingletonID
{
  key BUKRS as Bukrs,
  key BLART as Blart,
  @Consumption.hidden: true
  1 as SingletonID,
  _ZfiTpDocAll
}
