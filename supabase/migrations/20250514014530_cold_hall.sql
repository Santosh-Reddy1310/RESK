/*
  # Chat History Schema

  1. New Tables
    - `chat_history`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `title` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    - `chat_messages`
      - `id` (uuid, primary key)
      - `chat_id` (uuid, foreign key to chat_history)
      - `role` (text)
      - `content` (text)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users to manage their own data
*/

-- Create chat_history table
CREATE TABLE IF NOT EXISTS chat_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users NOT NULL,
  title text NOT NULL DEFAULT 'New Chat',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id uuid REFERENCES chat_history ON DELETE CASCADE NOT NULL,
  role text NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can manage their own chats"
  ON chat_history
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage messages in their chats"
  ON chat_messages
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM chat_history 
      WHERE chat_history.id = chat_messages.chat_id 
      AND chat_history.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM chat_history 
      WHERE chat_history.id = chat_messages.chat_id 
      AND chat_history.user_id = auth.uid()
    )
  );

-- Create function to update chat_history updated_at
CREATE OR REPLACE FUNCTION update_chat_history_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chat_history 
  SET updated_at = now()
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updating chat_history updated_at
CREATE TRIGGER update_chat_history_updated_at
  AFTER INSERT OR UPDATE ON chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_chat_history_updated_at();