--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-06-07 21:44:27

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 220 (class 1255 OID 17339)
-- Name: get_price_for_item(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_price_for_item(item_name text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    price NUMERIC;
BEGIN
    SELECT price INTO price
    FROM menu
    WHERE food_item = item_name;

    IF price IS NULL THEN
        RAISE EXCEPTION 'Item "%" not found in menu', item_name;
    END IF;

    RETURN price;
END;
$$;


ALTER FUNCTION public.get_price_for_item(item_name text) OWNER TO postgres;

--
-- TOC entry 221 (class 1255 OID 17340)
-- Name: get_total_order_price(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_total_order_price(order_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$DECLARE
    total NUMERIC := 0;
BEGIN
    SELECT SUM(o.quantity * f.price)
    INTO total
    FROM orders o
    JOIN food_items f ON o.item_id = f.item_id
    WHERE o.order_id = get_total_order_price.order_id;

    IF total IS NULL THEN
        RETURN 0;
    END IF;

    RETURN total;
END;

$$;


ALTER FUNCTION public.get_total_order_price(order_id integer) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 17341)
-- Name: insert_order_item(character varying, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_order_item(IN p_food_item character varying, IN p_quantity integer, IN p_order_id integer)
    LANGUAGE plpgsql
    AS $$DECLARE
    v_item_id INT;
    v_price NUMERIC(10,2);
BEGIN
    -- 1. Get item_id and price from food_items
    SELECT item_id, price
    INTO v_item_id, v_price
    FROM food_items
    WHERE name = p_food_item;

    -- 2. Check if item was found
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item "%" not found in food_items.', p_food_item;
    END IF;

    -- 3. Insert into orders table
    INSERT INTO orders(order_id, item_id, quantity, total_price)
    VALUES (p_order_id, v_item_id, p_quantity, v_price * p_quantity);
END;
$$;


ALTER PROCEDURE public.insert_order_item(IN p_food_item character varying, IN p_quantity integer, IN p_order_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 17312)
-- Name: food_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.food_items (
    item_id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    price numeric(10,2) DEFAULT NULL::numeric
);


ALTER TABLE public.food_items OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17319)
-- Name: order_tracking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_tracking (
    order_id integer NOT NULL,
    status character varying(255) DEFAULT NULL::character varying
);


ALTER TABLE public.order_tracking OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17325)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer,
    total_price numeric(10,2) DEFAULT NULL::numeric
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 4909 (class 0 OID 17312)
-- Dependencies: 217
-- Data for Name: food_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.food_items (item_id, name, price) FROM stdin;
1	Pav Bhaji	6.00
2	Chole Bhature	7.00
3	Pizza	8.00
4	Mango Lassi	5.00
5	Masala Dosa	6.00
6	Vegetable Biryani	9.00
7	Vada Pav	4.00
8	Rava Dosa	7.00
9	Samosa	5.00
\.


--
-- TOC entry 4910 (class 0 OID 17319)
-- Dependencies: 218
-- Data for Name: order_tracking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_tracking (order_id, status) FROM stdin;
40	delivered
41	in transit
42	in progress
43	in progress
44	in progress
45	in progress
46	in progress
47	in progress
\.


--
-- TOC entry 4911 (class 0 OID 17325)
-- Dependencies: 219
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, item_id, quantity, total_price) FROM stdin;
40	1	2	12.00
40	3	1	8.00
41	4	3	15.00
41	6	2	18.00
41	9	4	20.00
42	3	3	24.00
42	9	2	10.00
43	1	2	12.00
43	9	3	15.00
44	3	2	16.00
44	9	2	10.00
45	3	2	16.00
45	9	2	10.00
46	9	2	10.00
46	5	4	24.00
46	3	2	16.00
47	9	2	10.00
47	3	3	24.00
47	8	2	14.00
\.


--
-- TOC entry 4757 (class 2606 OID 17318)
-- Name: food_items food_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_items
    ADD CONSTRAINT food_items_pkey PRIMARY KEY (item_id);


--
-- TOC entry 4759 (class 2606 OID 17324)
-- Name: order_tracking order_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_tracking
    ADD CONSTRAINT order_tracking_pkey PRIMARY KEY (order_id);


--
-- TOC entry 4762 (class 2606 OID 17330)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id, item_id);


--
-- TOC entry 4760 (class 1259 OID 17336)
-- Name: idx_orders_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_item_id ON public.orders USING btree (item_id);


--
-- TOC entry 4763 (class 2606 OID 17331)
-- Name: orders orders_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_ibfk_1 FOREIGN KEY (item_id) REFERENCES public.food_items(item_id);


-- Completed on 2025-06-07 21:44:27

--
-- PostgreSQL database dump complete
--

