@EndUserText.label: 'Copy ZFI_TP_DOC'
define abstract entity ZD_CopyZfiTpDocP
{
  @EndUserText.label: 'New Company Code'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Bukrs' )
  Bukrs : BUKRS;
  @EndUserText.label: 'New Document Type'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Blart' )
  Blart : BLART;
}
