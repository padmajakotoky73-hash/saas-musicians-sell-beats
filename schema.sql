```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pg_crypto for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table (maps to Supabase auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  username TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policies for users
CREATE POLICY "Users can view their own profile" 
ON public.users FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON public.users FOR UPDATE USING (auth.uid() = id);

-- Beats table
CREATE TABLE public.beats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  bpm INTEGER NOT NULL,
  key TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  audio_url TEXT NOT NULL,
  cover_art_url TEXT,
  is_exclusive BOOLEAN DEFAULT FALSE,
  is_free BOOLEAN DEFAULT FALSE,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.beats ENABLE ROW LEVEL SECURITY;

-- Create policies for beats
CREATE POLICY "Beats are viewable by everyone"
ON public.beats FOR SELECT USING (TRUE);

CREATE POLICY "Users can manage their own beats"
ON public.beats 
FOR ALL USING (auth.uid() = user_id);

-- Indexes for beats
CREATE INDEX idx_beats_user_id ON public.beats(user_id);
CREATE INDEX idx_beats_price ON public.beats(price);
CREATE INDEX idx_beats_bpm ON public.beats(bpm);
CREATE INDEX idx_beats_key ON public.beats(key);
CREATE INDEX idx_beats_tags ON public.beats USING GIN(tags);

-- Purchases table
CREATE TABLE public.purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  beat_id UUID NOT NULL REFERENCES public.beats(id) ON DELETE CASCADE,
  amount DECIMAL(10, 2) NOT NULL,
  license_type TEXT NOT NULL,
  transaction_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;

-- Create policies for purchases
CREATE POLICY "Users can view their own purchases"
ON public.purchases FOR SELECT USING (auth.uid() = buyer_id);

CREATE POLICY "Beat creators can view purchases of their beats"
ON public.purchases FOR SELECT 
USING (auth.uid() IN (
  SELECT user_id FROM public.beats WHERE id = beat_id
));

-- Indexes for purchases
CREATE INDEX idx_purchases_buyer_id ON public.purchases(buyer_id);
CREATE INDEX idx_purchases_beat_id ON public.purchases(beat_id);

-- Favorites table
CREATE TABLE public.favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  beat_id UUID NOT NULL REFERENCES public.beats(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, beat_id)
);

-- Enable RLS
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- Create policies for favorites
CREATE POLICY "Users can manage their own favorites"
ON public.favorites 
FOR ALL USING (auth.uid() = user_id);

-- Indexes for favorites
CREATE INDEX idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX idx_favorites_beat_id ON public.favorites(beat_id);

-- Function to update timestamps
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for timestamp updates
CREATE TRIGGER update_users_timestamp
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_beats_timestamp
BEFORE UPDATE ON public.beats
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Seed data
INSERT INTO public.users (id, email, username, avatar_url) VALUES
('11111111-1111-1111-1111-111111111111', 'producer@example.com', 'hitmaker', 'https://example.com/avatar1.jpg'),
('22222222-2222-2222-2222-222222222222', 'artist@example.com', 'vocalist', 'https://example.com/avatar2.jpg');

INSERT INTO public.beats (id, user_id, title, description, bpm, key, price, audio_url, cover_art_url, tags) VALUES
('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Dreamy Piano', 'Chill piano loop with soft drums', 85, 'C#m', 29.99, 'https://example.com/audio1.mp3', 'https://example.com/cover1.jpg', '{piano,chill,lo-fi}'),
('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'Trap Banger', 'Hard hitting trap beat', 140, 'F#m', 49.99, 'https://example.com/audio2.mp3', 'https://example.com/cover2.jpg', '{trap,hard,808}');

INSERT INTO public.favorites (id, user_id, beat_id) VALUES
('55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333');
```