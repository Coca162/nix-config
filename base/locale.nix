{hostVars, ...}: {
  time.timeZone = hostVars.timezone;
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MEASUREMENT = "bg_BG.UTF-8"; # Imperial metrics?! Couldn't be me.
  };
}
