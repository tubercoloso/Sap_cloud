@EndUserText.label: 'Copy ZFI_STATO'
define abstract entity ZD_CopyZfiStatoP
{
  @EndUserText.label: 'New Code'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Code' )
  Code : abap.int4;
}
