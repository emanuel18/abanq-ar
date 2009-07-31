/***************************************************************************
                 opcionestv.qs  -  description
                             -------------------
    begin                : lun sep 21 2004
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

////////////////////////////////////////////////////////////////////////////
//// DECLARACION ///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

/** @class_declaration interna */
//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////
class interna {
    var ctx:Object;
    function interna( context ) { this.ctx = context; }
    function init() { this.ctx.interna_init(); }
    function validateForm() { return this.ctx.interna_validateForm(); }
    function main() { this.ctx.interna_main(); }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
    function oficial( context ) { interna( context ); } 
	function cambiarDirWeb() { return this.ctx.oficial_cambiarDirWeb() ;}
}
//// OFICIAL /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration silixFtpserver */
//////////////////////////////////////////////////////////////////
//// SILIXFTPSERVER /////////////////////////////////////////////
class silixFtpserver extends oficial {
    function silixFtpserver( context ) { oficial( context ); } 
    	function init() { this.ctx.silixFtpserver_init(); }
	function actualizarPassword(pass:String) {
		return this.ctx.silixFtpserver_actualizarPassword(pass);
	}
}
//// SILIXFTPSERVER /////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////
class head extends silixFtpserver {
    function head( context ) { silixFtpserver ( context ); }
}
//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_declaration ifaceCtx */
/////////////////////////////////////////////////////////////////
//// INTERFACE  /////////////////////////////////////////////////
class ifaceCtx extends head {
    function ifaceCtx( context ) { head( context ); }
}

const iface = new ifaceCtx( this );
//// INTERFACE  /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
//// DEFINICION ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

/** @class_definition interna */
//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////

function init() {
    this.iface.init();
}

function main() {
    this.iface.main();
}

function interna_init() 
{
	connect( this.child( "pbnCambiarDirWeb" ), "clicked()", this, "iface.cambiarDirWeb" );
	this.child("fdbRutaWeb").setDisabled(true);

	this.child("fdbTextoPre").setTextFormat(0);
	this.child("fdbTextoPie").setTextFormat(0);
}

function interna_validateForm() 
{
	var cursor:FLSqlCursor = this.cursor();
	var util:FLUtil = new FLUtil();

	if (cursor.valueBuffer("enviogratis")) {
		if (!cursor.valueBuffer("codenviogratis") || !cursor.valueBuffer("enviogratisdesde")) {
			MessageBox.information( util.translate( "scripts", "Debes rellenar todos los datos de env�o gratuito" ),
									MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton );
			return false;
		}
	}
	
	return true;
}

function interna_main()
{
	var f = new FLFormSearchDB("opcionestv");
	var cursor:FLSqlCursor = f.cursor();

	cursor.select();
	if (!cursor.first())
			cursor.setModeAccess(cursor.Insert);
	else
			cursor.setModeAccess(cursor.Edit);

	f.setMainWidget();
	cursor.refreshBuffer();
	var commitOk:Boolean = false;
	var acpt:Boolean;
	cursor.transaction(false);
	while (!commitOk) {
		acpt = false;
		f.exec("rutaweb");
		acpt = f.accepted();
		if (!acpt) {
			if (cursor.rollback())
					commitOk = true;
		} else {
			if (cursor.commitBuffer()) {
					cursor.commit();
					commitOk = true;
			}
		}
		f.close();
	}
}


//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////

function oficial_cambiarDirWeb()
{
	var util:FLUtil = new FLUtil();
	var ruta:String = FileDialog.getExistingDirectory( util.translate( "scripts", "" ), util.translate( "scripts", "RUTA A LOS MODULOS" ) );
	
	if ( !File.isDir( ruta ) ) {
		MessageBox.information( util.translate( "scripts", "Ruta err�nea" ),
								MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton );
		return;
	}
	debug(ruta);
	this.child("fdbRutaWeb").setValue(ruta);
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_declaration silixFtpserver */
//////////////////////////////////////////////////////////////////
//// SILIXFTPSERVER /////////////////////////////////////////////

function silixFtpserver_init() {
	this.iface.__init();

	this.child("lineEditPass").text = this.cursor().valueBuffer("ftppassword");
	connect(this.child("lineEditPass"), "textChanged(QString)", this, "iface.actualizarPassword()");
}

function silixFtpserver_actualizarPassword(pass:String) {
	var cursor:FLSqlCursor = this.cursor();
	cursor.setValueBuffer("ftppassword", pass);
}

//// SILIXFTPSERVER /////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////
//// INTERFACE  /////////////////////////////////////////////////

//// INTERFACE  /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
