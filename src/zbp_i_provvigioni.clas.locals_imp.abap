class lhc_zi_provvigioni definition inheriting from cl_abap_behavior_handler.
  private section.

*    METHODS get_instance_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR ZfiProvvigioni RESULT result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for zfiprovvigioni result result.


    methods:
      get_instance_features for instance features
        importing keys request requested_features for zfiprovvigioni result result,
      validate for validate on save
        importing keys for zfiprovvigioni~validate,
      getdefaultsforcreate for read
        importing keys for function zfiprovvigioni~getdefaultsforcreate result result,

*    CLASS-METHODS:
      check_document  importing it_string   type string_table
                                i_company   type bukrs
                      returning value(r_ok) type abap_boolean,
      image_icon for determine on modify
        importing keys for zfiprovvigioni~image_icon,
      existance_doc for validate on save
        importing keys for zfiprovvigioni~existance_doc.
endclass.

class lhc_zi_provvigioni implementation.

*  METHOD get_instance_authorizations.
*
*  ENDMETHOD.

  method get_global_authorizations.
  endmethod.

  method get_instance_features.
    read entities of zi_provvigioni in local mode
          entity zfiprovvigioni
          fields ( id provvstatus provvtype ) with corresponding #( keys )
          result data(records).

    loop at records into data(record).

      data(lv_enabled) = cond #( when record-provvtype = 'A' then if_abap_behv=>fc-f-read_only
                                 when record-provvtype = 'M' then if_abap_behv=>fc-f-unrestricted
                                 else if_abap_behv=>fc-f-unrestricted ).

      result = value #( base result
        (
          %tky = record-%tky
          %features-%field-companycode = lv_enabled
          %features-%field-agentcode = lv_enabled
          %features-%field-customercode = lv_enabled
          %features-%field-postingdate = lv_enabled
          %features-%field-accountingdocument = lv_enabled
          %features-%field-fiscalyear = lv_enabled
          %features-%field-importoprovvvalint = lv_enabled
          %features-%field-importoprovvvalintcurrency = lv_enabled
          %features-%field-importoprovvvaldoc = lv_enabled
          %features-%field-importoprovvvaldoccurrency = lv_enabled
*          %features-%field-importoimponibile = lv_enabled
*          %features-%field-importoimponibilecurrency = lv_enabled
*          %features-%field-importoimponibileInt = lv_enabled
*          %features-%field-importoimponibilecurint = lv_enabled
*          %features-%field-importoimponibilepercentage = lv_enabled
          %features-%field-provvsymbol = lv_enabled
          %features-%field-document = lv_enabled

          %features-%field-documentmaturanda = if_abap_behv=>fc-f-unrestricted
          %features-%field-documentmaturata = if_abap_behv=>fc-f-unrestricted
          %features-%field-documentfdr = if_abap_behv=>fc-f-unrestricted
          %features-%field-documentfatturaagente = if_abap_behv=>fc-f-unrestricted

          %features-%field-provvtype = if_abap_behv=>fc-f-all
*          %features-%field-agentcode = if_abap_behv=>fc-f-mandatory
*          %features-%field-companycode = if_abap_behv=>fc-f-mandatory
*          %features-%field-importoprovvvalint = if_abap_behv=>fc-f-mandatory
*          %features-%field-importoprovvvalintcurrency = if_abap_behv=>fc-f-mandatory
*          %features-%field-importoprovvvaldoc = if_abap_behv=>fc-f-mandatory
*          %features-%field-importoprovvvaldoccurrency = if_abap_behv=>fc-f-mandatory
*          %features-%field-provvstatus = if_abap_behv=>fc-f-mandatory
        )
      ).

    endloop.

  endmethod.

  method validate.

    " Per Documento maturanda, Documento fdr e Documento fattura si richiede controllo che
    " il documento inserito effettivamente esista a sistema (deve esistere tale documento
    " per la concatenazione in BKPF per BUKRS BELNR GJAHR).

    data ls_reported like line of reported-zfiprovvigioni.

    read entities of zi_provvigioni in local mode
      entity zfiprovvigioni
      all fields
      with corresponding #( keys )
      result data(entities).


    data(lt_beh) = value string_table(
        ( conv string( 'Document' ) )
        ( conv string( 'DocumentFatturaAgente' ) )
        ( conv string( 'DocumentFdr' ) )
        ( conv string( 'DocumentMaturanda' ) )
        ( conv string( 'DocumentMaturata' ) )
    ).


    data(lt_mandatory) = value string_table(
        ( conv string( 'AgentCode' ) )
        ( conv string( 'CompanyCode' ) )
        ( conv string( 'ImportoProvvValInt' ) )
        ( conv string( 'ImportoProvvValIntCurrency' ) )
        ( conv string( 'ImportoProvvValDoc' ) )
        ( conv string( 'ImportoProvvValDocCurrency' ) )
    ).


    loop at entities into data(entity).

      loop at lt_mandatory into data(lv_mandatory).
        assign component |{ lv_mandatory }|
        of structure entity
        to field-symbol(<fs_element_mand>).

        if <fs_element_mand> is initial.
          clear ls_reported.
          ls_reported-%tky = entity-%tky.
          ls_reported-%msg = new_message(
                   id       = 'ZFI_MSG_PROVVIGIONI'
                   number   = 003
                   v1       = lv_mandatory
                   severity = if_abap_behv_message=>severity-error ).

          assign component |%element-{ lv_mandatory }|
              of structure ls_reported
              to field-symbol(<fs_element_reported>).
          if sy-subrc = 0.
            <fs_element_reported> = if_abap_behv=>mk-on.
          endif.
          append ls_reported to reported-zfiprovvigioni.
          append value #( %tky = entity-%tky ) to failed-zfiprovvigioni.

        else.
          data(lv_error_mand) = abap_false.
          case lv_mandatory.
            when 'AgentCode'.
              select single supplier
              from i_supplier
              with privileged access
              where supplier = @<fs_element_mand>
              into @data(lv_supplier_mand).
              if sy-subrc <> 0.
                lv_error_mand = abap_true.
              endif.
            when 'CompanyCode'.
              select single companycode
              from i_companycode
              with privileged access
              where companycode = @<fs_element_mand>
              into @data(lv_comp_mand).
              if sy-subrc <> 0.
                lv_error_mand = abap_true.
              endif.
          endcase.
          if lv_error_mand = abap_true.
            clear ls_reported.
            ls_reported-%tky = entity-%tky.
            ls_reported-%msg = new_message(
                     id       = 'ZFI_MSG_PROVVIGIONI'
                     number   = 004
                     v1       = <fs_element_mand>
                     v2       = lv_mandatory
                     severity = if_abap_behv_message=>severity-error ).

            assign component |%element-{ lv_mandatory }|
                of structure ls_reported
                to field-symbol(<fs_element_reported_mand>).
            if sy-subrc = 0.
              <fs_element_reported_mand> = if_abap_behv=>mk-on.
            endif.
            append ls_reported to reported-zfiprovvigioni.
            append value #( %tky = entity-%tky ) to failed-zfiprovvigioni.
          endif.
        endif.
      endloop.

*      IF entity-ProvvType = 'A'.
*
*        APPEND VALUE #( %tky = entity-%tky ) TO failed-zfiprovvigioni.
*
*        APPEND VALUE #(
*          %tky = entity-%tky
*          %msg = new_message(
*            id       = 'ZFI_MSG_PROVVIGIONI'
*            number   = 001
*            severity = if_abap_behv_message=>severity-error )
*          %element-ProvvType = if_abap_behv=>mk-on
*        ) TO reported-zfiprovvigioni.
*
*      ENDIF.

      exit.

      loop at lt_beh into data(lv_beh).

        assign component |{ lv_beh }|
          of structure entity
          to field-symbol(<fs_element>).

        split <fs_element> at '-' into table data(lt_document). " [1] doc; [2] year;
        data(lv_check_document) = check_document( i_company = entity-companycode it_string = lt_document ).

        if lv_check_document is initial.
          clear ls_reported.
          ls_reported-%tky = entity-%tky.
          ls_reported-%msg = new_message(
                   id       = 'ZFI_MSG_PROVVIGIONI'
                   number   = 002
                   v1       = <fs_element>
                   severity = if_abap_behv_message=>severity-error ).

          assign component |%element-{ lv_beh }|
              of structure ls_reported
              to field-symbol(<fs_element_reported_beh>).
          if sy-subrc = 0.
            <fs_element_reported_beh> = if_abap_behv=>mk-on.
          endif.
          append ls_reported to reported-zfiprovvigioni.
          append value #( %tky = entity-%tky ) to failed-zfiprovvigioni.
        endif.

      endloop.

*      SPLIT entity-Document AT '-' INTO TABLE DATA(lt_document). " [1] doc; [2] year;
*      DATA(lv_check_document) = check_document( i_company = entity-CompanyCode i_string = lt_document ).
*
*      SPLIT entity-DocumentFatturaAgente AT '-' INTO TABLE DATA(lt_document_fattura_agente). " [1] doc; [2] year;
*      DATA(lv_check_document_agente) = check_document( i_company = entity-CompanyCode i_string = lt_document ).
*
*      SPLIT entity-DocumentFdr AT '-' INTO TABLE DATA(lt_document_fdr). " [1] doc; [2] year;
*      DATA(lv_check_document_fdr) = check_document( i_company = entity-CompanyCode i_string = lt_document ).
*
*      SPLIT entity-DocumentMaturanda AT '-' INTO TABLE DATA(lt_document_maturanda). " [1] doc; [2] year;
*      DATA(lv_check_document_maturanda) = check_document( i_company = entity-CompanyCode i_string = lt_document ).
*
*      SPLIT entity-DocumentMaturata AT '-' INTO TABLE DATA(lt_document_maturata). " [1] doc; [2] year;
*      DATA(lv_check_document_maturata) = check_document( i_company = entity-CompanyCode i_string = lt_document ).

    endloop.

  endmethod.

  method check_document.

    r_ok = space.

    try.
        data(lv_company) = i_company.
        data(lv_document) = |{ conv belnr_d( it_string[ 1 ] ) alpha = in }|.
        data(lv_year) = conv gjahr( it_string[ 2 ] ).
        if lv_document is not initial and lv_year is not initial.
          select count( * ) from i_journalentry
             with privileged access
              where companycode eq @lv_company
                and accountingdocument eq @lv_document
                and fiscalyear eq @lv_year
                into @data(lv_count).
          if sy-dbcnt > 0.
            r_ok = 'X'.
          endif.
        endif.
      catch cx_sy_itab_line_not_found.
        data(cc) = 'o'.
    endtry.
  endmethod.

  method getdefaultsforcreate.
    result = value #( for key in keys (
               %cid = key-%cid
               %param-provvtype = 'M'
                ) ).
  endmethod.

  method image_icon.

    read entities of zi_provvigioni in local mode
        entity zfiprovvigioni
        all fields
        with corresponding #( keys )
   result data(entities).

    select single icon_uri from zfi_tp_provv
     where icon_id eq 'M'
    into @data(lv_manual_icon).

    select single icon_uri from zfi_tp_provv
     where icon_id eq 'A'
    into @data(lv_auto_icon).


    ""  loop at entities assigning field-symbol(<line>).

    modify entities of zi_provvigioni in local mode entity zfiprovvigioni
     update fields ( provvsymbol  )
     with value #( for <line> in entities (   %tky        = <line>-%tky
                    provvsymbol = cond #( when <line>-provvtype eq 'A' then lv_auto_icon
                                          when <line>-provvtype eq 'M' then lv_manual_icon )
                    %control-provvsymbol = if_abap_behv=>mk-on ) )
     failed data(failed).

    "" endloop.



  endmethod.

  method existance_doc.

    data ls_reported like line of reported-zfiprovvigioni.

    read entities of zi_provvigioni in local mode
        entity zfiprovvigioni
        all fields
          with corresponding #( keys )
    result data(entities).

    data(lt_beh) = value string_table( ( conv string( 'Document' ) )
                                       ( conv string( 'DocumentFatturaAgente' ) )
                                       ( conv string( 'DocumentFdr' ) )
                                       ( conv string( 'DocumentMaturanda' ) )
                                       ( conv string( 'DocumentMaturata' ) )
                                       ( conv string( 'accountingdocument' ) )
                                    ).


    loop at entities into data(entity).

      loop at lt_beh into data(lv_beh).

        assign component |{ lv_beh }|
          of structure entity
          to field-symbol(<fs_element>).

        split <fs_element> at '-' into table data(lt_document). " [1] doc; [2] year;
        if lt_document is initial.
          continue.
        endif.

        if lv_beh eq 'accountingdocument'.
          append entity-fiscalyear to lt_document.
        endif.

        data(lv_check_document) = check_document( i_company = entity-companycode it_string = lt_document ).

        clear lt_document.

        if lv_check_document is initial.
          clear ls_reported.
          ls_reported-%tky = entity-%tky.
          ls_reported-%msg = new_message(
                   id       = 'ZFI_MSG_PROVVIGIONI'
                   number   = 002
                   v1       = <fs_element>
                   severity = if_abap_behv_message=>severity-error ).

          assign component |%element-{ lv_beh }|
              of structure ls_reported
              to field-symbol(<fs_element_reported_beh>).
          if sy-subrc = 0.
            <fs_element_reported_beh> = if_abap_behv=>mk-on.
          endif.
          append ls_reported to reported-zfiprovvigioni.
          append value #( %tky = entity-%tky ) to failed-zfiprovvigioni.
        endif.

      endloop.

    endloop.

  endmethod.

endclass.
