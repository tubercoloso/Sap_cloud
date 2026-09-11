@EndUserText.label: 'ZFI_TP_PROVV'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_ZfiTpProvv
  as select from zfi_tp_provv
  association to parent ZI_ZfiTpProvv_S as _ZfiTpProvvAll on $projection.SingletonID = _ZfiTpProvvAll.SingletonID
{
  key icon_id as IconId,
  icon_uri as IconUri,
  @Semantics.text: true
  description as Description,
  @Consumption.hidden: true
  1 as SingletonID,
  _ZfiTpProvvAll
}
