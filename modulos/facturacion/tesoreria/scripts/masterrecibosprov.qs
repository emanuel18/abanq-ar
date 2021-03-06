/***************************************************************************
                 masterrecibosprov.qs  -  description
                             -------------------
    begin                : lun abr 26 2004
    copyright            : (C) 2004 by InfoSiAL S.L.
    email                : mail@infosial.com
 ***************************************************************************/
/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

/** @file */

/** @class_declaration interna */
////////////////////////////////////////////////////////////////////////////
//// DECLARACION ///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////
class interna {
    var ctx:Object;
    function interna( context ) { this.ctx = context; }
    function init() { this.ctx.interna_init(); }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
    function oficial( context ) { interna( context ); } 
}
//// OFICIAL /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration proveed */
//////////////////////////////////////////////////////////////////
//// PROVEED /////////////////////////////////////////////////////
class proveed extends oficial {
    function proveed( context ) { oficial( context ); } 
	function imprimir(codRecibo:String) {
		return this.ctx.oficial_imprimir(codRecibo)
	}
}
//// PROVEED /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////


/** @class_declaration fechas */
/////////////////////////////////////////////////////////////////
//// FECHAS /////////////////////////////////////////////////
class fechas extends proveed {
	var tdbRecords:FLTableDB;
	var fechaDesde:Object;
	var fechaHasta:Object;
	var cbxEstado:Object;

    function fechas( context ) { proveed ( context ); }
	function init() {
		this.ctx.fechas_init();
	}
	function actualizarFiltro() {
		return this.ctx.fechas_actualizarFiltro();
	}
	function actualizarFiltroCombo() {
		return this.ctx.fechas_actualizarFiltroCombo();
	}
}
//// FECHAS /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


/** @class_declaration ordenCampos */
/////////////////////////////////////////////////////////////////
//// ORDEN_CAMPOS ///////////////////////////////////////////////
class ordenCampos extends fechas {
    function ordenCampos( context ) { fechas ( context ); }
	function init() {
		this.ctx.ordenCampos_init();
	}
}
//// ORDEN_CAMPOS ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_declaration head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////
class head extends ordenCampos {
    function head( context ) { ordenCampos ( context ); }
}
//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_declaration ifaceCtx */
/////////////////////////////////////////////////////////////////
//// INTERFACE  /////////////////////////////////////////////////
class ifaceCtx extends head {
    function ifaceCtx( context ) { head( context ); }
	function pub_imprimir(codRecibo:String) {
		return this.imprimir(codRecibo);
	}
}

const iface = new ifaceCtx( this );
//// INTERFACE  /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition interna */
////////////////////////////////////////////////////////////////////////////
//// DEFINICION ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////

function init() {
    this.iface.init();
}

function interna_init()
{
		form.child("tableDBRecords").setEditOnly(true);
		connect(form.child("toolButtonPrint"), "clicked()", this, "iface.imprimir");
}
//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////

//// OFICIAL ////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition proveed */
/////////////////////////////////////////////////////////////////
//// PROVEED ////////////////////////////////////////////////////
/** \D
Crea un informe con el listado de registros de la remesa. Funciona cuando est� cargado el m�dulo de informes
\end */
function oficial_imprimir(codRecibo:String)
{
	if (sys.isLoadedModule("flfactinfo")) {
		var codigo:String;
		if (codRecibo) {
			codigo = codRecibo;
		} else {
			if (!this.cursor().isValid())
				return;
			codigo = this.cursor().valueBuffer("codigo");
		}
		var curImprimir:FLSqlCursor = new FLSqlCursor("i_recibosprov");
		curImprimir.setModeAccess(curImprimir.Insert);
		curImprimir.refreshBuffer();
		curImprimir.setValueBuffer("descripcion", "temp");
		curImprimir.setValueBuffer("d_recibosprov_codigo", codigo);
		curImprimir.setValueBuffer("h_recibosprov_codigo", codigo);
		flfactinfo.iface.pub_lanzarInforme(curImprimir, "i_recibosprov");
	} else
			flfactppal.iface.pub_msgNoDisponible("Informes");
}
//// PROVEED ////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


/** @class_definition fechas */
/////////////////////////////////////////////////////////////////
//// FECHAS /////////////////////////////////////////////////////

function fechas_init()
{
	this.iface.__init();

	this.iface.tdbRecords = this.child("tableDBRecords");
	this.iface.fechaDesde = this.child("dateFrom");
	this.iface.fechaHasta = this.child("dateTo");
	this.iface.cbxEstado = this.child("cbxEstado");

	var d = new Date();
	this.iface.fechaDesde.date = new Date(d.getYear(), d.getMonth(), 1);
	this.iface.fechaHasta.date = new Date();

	connect(this.iface.fechaDesde, "valueChanged(const QDate&)", this, "iface.actualizarFiltro");
	connect(this.iface.fechaHasta, "valueChanged(const QDate&)", this, "iface.actualizarFiltro");
	connect(this.iface.cbxEstado, "activated(int)", this, "iface.actualizarFiltroCombo");

	this.iface.actualizarFiltro();
}

function fechas_actualizarFiltro()
{
	var desde:String = this.iface.fechaDesde.date.toString().left(10);
	var hasta:String = this.iface.fechaHasta.date.toString().left(10);

	if (desde == "" || hasta == "")
		return;

	var estado:Number = this.iface.cbxEstado.currentItem;
	var filtro:String = "fechav >= '" + desde + "' AND fechav <= '" + hasta + "'";

	switch (estado) {
		case 0: {
			break;
		}
		case 1: {
			filtro += " AND estado = 'Emitido'";
			break;
		}
		case 2: {
			filtro += " AND estado = 'Pagado'";
			break;
		}
	}

	this.cursor().setMainFilter(filtro);

	this.iface.tdbRecords.refresh();
	this.cursor().last();
	this.iface.tdbRecords.setCurrentRow(this.cursor().at());
}

/* La �nica diferencia entre esta funci�n y "actualizarFiltro()" es el setFocus() que aparece al final.
   Este setFocus() es pr�ctico cuando se cambia el combobox, pero resulta molesto cuando se cambia la fecha.
 */
function fechas_actualizarFiltroCombo()
{
	var desde:String = this.iface.fechaDesde.date.toString().left(10);
	var hasta:String = this.iface.fechaHasta.date.toString().left(10);

	if (desde == "" || hasta == "")
		return;

	var estado:Number = this.iface.cbxEstado.currentItem;
	var filtro:String = "fechav >= '" + desde + "' AND fechav <= '" + hasta + "'";

	switch (estado) {
		case 0: {
			break;
		}
		case 1: {
			filtro += " AND estado = 'Emitido'";
			break;
		}
		case 2: {
			filtro += " AND estado = 'Pagado'";
			break;
		}
	}

	this.cursor().setMainFilter(filtro);

	this.iface.tdbRecords.refresh();
	this.cursor().last();
	this.iface.tdbRecords.setCurrentRow(this.cursor().at());
	this.iface.tdbRecords.setFocus();
}

//// FECHAS /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition ordenCampos */
/////////////////////////////////////////////////////////////////
//// ORDEN_CAMPOS ///////////////////////////////////////////////

function ordenCampos_init()
{
	this.iface.__init();

	var orden:Array = [ "codigo", "estado", "nombreproveedor", "importe", "coddivisa", "importeeuros", "fecha", "fechav", "idremesa", "idpagomulti", "codproveedor", "cifnif", "direccion", "codpostal", "ciudad", "provincia", "codpais", "texto" ];

	this.iface.tdbRecords.setOrderCols(orden);
	this.iface.tdbRecords.setFocus();
}

//// ORDEN_CAMPOS ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition ifaceCtx */
/////////////////////////////////////////////////////////////////
//// INTERFACE  /////////////////////////////////////////////////

//// INTERFACE  /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
