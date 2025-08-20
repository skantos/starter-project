# Articles
Collection: articles
Document: {articleId}

Fields:
- title: string (required)
- description: string
- content: string
- author: string
- authorId: string (optional, required if rules usan auth)
- url: string
- thumbnailURL: string (required, path en storage: "media/articles/{articleId}.jpg")
- publishedAt: timestamp (or ISO string)
- createdAt: timestamp (server)
- updatedAt: timestamp (server)
- status: string in ["draft", "published"]
- tags: array<string>
Indexes: none initially