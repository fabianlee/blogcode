/^Package:/{PKG= $2}
/^Status: .*user installed/{print PKG}
