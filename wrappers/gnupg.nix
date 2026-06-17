_: {
  # These are the defaults home-manager sets
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/gpg.nix#L286-L304
  # idk if I actually want to do this
  # I assume actual defaults it sets are fine
  # but the docs are kinda ass so eh
  options.settings.default = {
    personal-cipher-preferences = "AES256 AES192 AES";
    personal-digest-preferences = "SHA512 SHA384 SHA256";
    personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
    default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
    cert-digest-algo = "SHA512";
    s2k-digest-algo = "SHA512";
    s2k-cipher-algo = "AES256";
    display-charset = "utf-8";
    no-comments = true;
    no-emit-version = true;
    keyid-format = "0xlong";
    list-options = "show-uid-validity";
    verify-options = "show-uid-validity";
    with-fingerprint = true;
    require-cross-certification = true;
    no-symkey-cache = true;
  };
}
