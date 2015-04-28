-- Table: gas_stations

DROP TABLE gas_stations;

CREATE TABLE gas_stations
(
  id serial NOT NULL,
  lat decimal,
  lon decimal,
  brand text,
  operator text,
  name text,
  addr_country text,  
  addr_city text,  
  addr_street text,
  addr_housenumber text,  
  addr_postcode text,
  phone text,
  shop text,
  wheelchair text,
  opening_hours text,
  payment_cash text,
  payment_mastercard text,
  payment_visa text,
  payment_maestro text,
  payment_dkv text,
  payment_uta text,
  payment_fuel_cards text,
  fuel_diesel text,
  fuel_gtl_diesel text,
  fuel_hgv_diesel text,    
  fuel_octane_91 text,
  fuel_octane_95 text,
  fuel_octane_98 text,
  fuel_octane_100 text,
  fuel_octane_102 text,  
  fuel_1_25 text,
  fuel_1_50 text,
  fuel_biodiesel text,
  fuel_svo text,
  fuel_e10 text,
  fuel_e85 text,
  fuel_biogas text,
  fuel_lpg text,
  fuel_cng text,
  fuel_LH2 text,
  fuel_adblue text,  
  CONSTRAINT gas_stations_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gas_stations
  OWNER TO postgres;
