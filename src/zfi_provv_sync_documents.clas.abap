class zfi_provv_sync_documents definition
  public
  final
  create public .

  public section.

    interfaces if_apj_dt_exec_object .
    interfaces if_apj_rt_exec_object .
    interfaces if_oo_adt_classrun .

    types tt_create type table for create zc_provvigioni.

    data t_belnr type range of vbeln.

  protected section.

    methods: run.

  private section.
ENDCLASS.



CLASS ZFI_PROVV_SYNC_DOCUMENTS IMPLEMENTATION.


  method if_apj_dt_exec_object~get_parameters.

    et_parameter_def = value #( ( selname        = 'S_BUKRS'
                                 kind            = if_apj_dt_exec_object=>select_option
                                 datatype        = 'C'
                                 length          = '4'
                                 changeable_ind  = abap_true
                                 param_text      = 'Società'
                                )
                                ( selname        = 'S_GHJAR'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'C'
                                  length         = '4'
                                  changeable_ind = abap_true
                                  param_text     = 'Esercizio'
                                )
                                ( selname        = 'S_DATUM'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'D'
                                  changeable_ind = abap_true
                                  param_text     = 'Data registrazione'
                                )
                                ( selname        = 'S_VBELN'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'C'
                                  length         = '10'
                                  changeable_ind = abap_true
                                  param_text     = 'Numero documento'
                                )
                                ).

  endmethod.


  method run.

    data lv_amountin type wrbtr.

    data(lv_date) = xco_cp=>sy->date( )->subtract( iv_day = 4 )->as( xco_cp_time=>format->iso_8601_basic )->value.

    select _header~accountingdocument,
           _header~fiscalyear      ,
           _header~companycode     ,
           _item~debitcreditcode,
           _item~amountintransactioncurrency,
           _item~taxcode,
           _item~amountincompanycodecurrency,
           _header~documentdate,
           _header~postingdate,
           _header~isreversal,
           _header~isreversed,
           _header~reversedocument,
           _header~reversedocumentfiscalyear,
           _item~absoluteamountincocodecrcy,
           _item~companycodecurrency,
           _item~absoluteamountintransaccrcy,
           _item~transactioncurrency
   from i_journalentry   as _header
      inner join i_operationalacctgdocitem as _item on _header~accountingdocument   eq _item~accountingdocument
                                                   and _header~fiscalyear           eq _item~fiscalyear
                                                   and _header~companycode          eq _item~companycode
      inner join zfi_tp_doc            as _tp_doc   on _header~companycode          eq _tp_doc~bukrs
                                                   and _item~accountingdocumenttype eq _tp_doc~blart
      inner join zfi_conti_prov as _tp_conti_prov   on _header~companycode          eq _tp_conti_prov~bukrs
                                                   and _item~glaccount              eq _tp_conti_prov~hkont
      left join zc_provvigioni  as _provv           on _provv~accountingdocument    eq _header~accountingdocument
                                                   and _provv~fiscalyear            eq _header~fiscalyear
                                                   and _provv~companycode           eq _header~companycode
   where _header~postingdate >= @lv_date
     and _item~financialaccounttype = 'S'    " recupero solo le posizioni co.ge.
     and _item~taxtype is initial            " escludo le posizioni iva
     and _provv~id     is initial
   into table @data(lt_items).

    if sy-subrc ne 0.
      return.
    endif.

    loop at lt_items into data(ls_item) group by ( accountingdocument = ls_item-accountingdocument
                                                   fiscalyear         = ls_item-fiscalyear
                                                   companycode        = ls_item-companycode  ).

      clear: lv_amountin.

      loop at group ls_item assigning field-symbol(<line>).
        lv_amountin = lv_amountin + <line>-amountintransactioncurrency.
      endloop.

      select single supplier
        from i_operationalacctgdocitem
       where accountingdocument eq @ls_item-accountingdocument
         and fiscalyear         eq @ls_item-fiscalyear
         and companycode        eq @ls_item-companycode
         and (    financialaccounttype eq 'S'
               or financialaccounttype eq 'A'
               or financialaccounttype eq 'M' )
         and supplier is not initial
      into @data(lv_customer).

      try.
          data(lv_uuid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
        catch cx_uuid_error.
          return.
      endtry.

      data(lt_create) = value tt_create( ( %cid                        = lv_uuid
                                           companycode                 = ls_item-companycode
                                           agentcode                   = '' " VERIFICARE
                                           customercode                = lv_customer
                                           postingdate                 = ls_item-postingdate
                                           accountingdocument          = ls_item-accountingdocument
                                           fiscalyear                  = ls_item-fiscalyear
                                           importoprovvvalint          = ls_item-absoluteamountincocodecrcy
                                           importoprovvvalintcurrency  = ls_item-companycodecurrency
                                           importoprovvvaldoc          = ls_item-absoluteamountintransaccrcy
                                           importoprovvvaldoccurrency  = ls_item-transactioncurrency
                                           importoimponibile           = lv_amountin
                                           importoimponibilecurrency   = 'EUR'
                                           importoimponibilepercentage = 0
                                           provvtype                   = 'A'
                                           provvsymbol                 = ''
                                           provvstatus                 = 1
                                           documentmaturanda           = 0
                                           documentmaturata            = 0
                                           documentfdr                 = 0
                                           documentfatturaagente       = 0
                                           document                    = 0  ) ).


      modify entities of zc_provvigioni
       entity zfiprovvigioni
       create fields ( companycode
                       agentcode
                       customercode
                       postingdate
                       accountingdocument
                       fiscalyear
                       importoprovvvalint
                       importoprovvvalintcurrency
                       importoprovvvaldoc
                       importoprovvvaldoccurrency
                       importoimponibile
                       importoimponibilecurrency
                       importoimponibilepercentage
                       provvtype
                       provvsymbol
                       provvstatus
                       documentmaturanda
                       documentmaturata
                       documentfdr
                       documentfatturaagente
                       document  )
      with lt_create
      mapped data(mapped_002)
    reported data(reported_002)
      failed data(failed_002).

    endloop.

  endmethod.


  method if_apj_rt_exec_object~execute.

    t_belnr = value #( for wa in it_parameters where ( selname = 'S_VBELN' ) ( corresponding #( wa ) ) ).

    run(  ).

  endmethod.


  method if_oo_adt_classrun~main.
    run(  ).
  endmethod.
ENDCLASS.
