CLASS LHC_ZFITPPROVVALL DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PUBLIC SECTION.
    CONSTANTS:
      CO_ENTITY TYPE abp_entity_name VALUE `ZI_ZFITPPROVV_S`,
      CO_TRANSPORT_OBJECT TYPE mbc_cp_api=>indiv_transaction_obj_name VALUE `ZZFITPPROVV`,
      CO_AUTHORIZATION_ENTITY TYPE abp_entity_name VALUE `ZI_ZFITPPROVV`.

  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR ZfiTpProvvAll
        RESULT result,
      SELECTCUSTOMIZINGTRANSPTREQ FOR MODIFY
        IMPORTING
          KEYS FOR ACTION ZfiTpProvvAll~SelectCustomizingTransptReq
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZfiTpProvvAll
        RESULT result,
      EDIT FOR MODIFY
        IMPORTING
          KEYS FOR ACTION ZfiTpProvvAll~edit.
ENDCLASS.

CLASS LHC_ZFITPPROVVALL IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
  mbc_cp_api=>rap_bc_api( )->get_instance_features(
    transport_object   = co_transport_object
    entity             = co_entity
    keys               = REF #( keys )
    requested_features = REF #( requested_features )
    result             = REF #( result )
    failed             = REF #( failed )
    reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD SELECTCUSTOMIZINGTRANSPTREQ.
  mbc_cp_api=>rap_bc_api( )->select_transport_action(
    entity   = co_entity
    keys     = REF #( keys )
    result   = REF #( result )
    mapped   = REF #( mapped )
    failed   = REF #( failed )
    reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
    entity                   = co_authorization_entity
    requested_authorizations = REF #( requested_authorizations )
    result                   = REF #( result )
    reported                 = REF #( reported ) ).
  ENDMETHOD.
  METHOD EDIT.
  mbc_cp_api=>rap_bc_api( )->get_default_transport_request(
    transport_object = co_transport_object
    entity           = co_entity
    keys             = REF #( keys )
    mapped           = REF #( mapped )
    failed           = REF #( failed )
    reported         = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZFITPPROVVALL DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION.
ENDCLASS.

CLASS LSC_ZFITPPROVVALL IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
  mbc_cp_api=>rap_bc_api( )->record_changes(
    transport_object = lhc_ZfiTpProvvAll=>co_transport_object
    entity           = lhc_ZfiTpProvvAll=>co_entity
    create           = REF #( create )
    update           = REF #( update )
    delete           = REF #( delete )
    reported         = REF #( reported ) ).
  mbc_cp_api=>rap_bc_api( )->update_last_changed_date_time(
    maintenance_object = 'ZZFITPPROVV'
    entity             = lhc_ZfiTpProvvAll=>co_authorization_entity
    create             = REF #( create )
    update             = REF #( update )
    delete             = REF #( delete )
    reported           = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZFITPPROVV DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PUBLIC SECTION.
    CONSTANTS:
      CO_ENTITY TYPE abp_entity_name VALUE `ZI_ZFITPPROVV`.

  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR ZfiTpProvv
        RESULT result,
      COPY FOR MODIFY
        IMPORTING
          KEYS FOR ACTION ZfiTpProvv~Copy,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZfiTpProvv
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR ZfiTpProvv
        RESULT result,
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS_ZFITPPROVVALL FOR ZfiTpProvvAll~ValidateTransportRequest
          KEYS_ZFITPPROVV FOR ZfiTpProvv~ValidateTransportRequest.
ENDCLASS.

CLASS LHC_ZFITPPROVV IMPLEMENTATION.
  METHOD GET_GLOBAL_FEATURES.
  mbc_cp_api=>rap_bc_api( )->get_global_features(
    transport_object   = lhc_ZfiTpProvvAll=>co_transport_object
    entity             = co_entity
    requested_features = REF #( requested_features )
    result             = REF #( result )
    reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD COPY.
  mbc_cp_api=>rap_bc_api( )->copy_by_association(
    entity   = co_entity
    keys     = REF #( keys )
    mapped   = REF #( mapped )
    failed   = REF #( failed )
    reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
    entity                   = lhc_ZfiTpProvvAll=>co_authorization_entity
    requested_authorizations = REF #( requested_authorizations )
    result                   = REF #( result )
    reported                 = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
  mbc_cp_api=>rap_bc_api( )->get_action_features(
    entity             = co_entity
    keys               = REF #( keys )
    requested_features = REF #( requested_features )
    result             = REF #( result )
    failed             = REF #( failed )
    reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD VALIDATETRANSPORTREQUEST.
  mbc_cp_api=>rap_bc_api( )->validate_transport_request(
    transport_object = lhc_ZfiTpProvvAll=>co_transport_object
    entity           = lhc_ZfiTpProvvAll=>co_entity
    validation_keys  = VALUE #( ( REF #( keys_ZfiTpProvvAll ) )
                                ( REF #( keys_ZfiTpProvv ) ) )
    failed           = REF #( failed )
    reported         = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
